defmodule Excal.Recurrence.StreamTest do
  use ExUnit.Case, async: true

  alias Excal.Recurrence.Stream, as: RecurrenceStream

  describe "Stream.new/3" do
    test "returns a stream when valid inputs are given" do
      assert {:ok, stream} = RecurrenceStream.new("FREQ=DAILY", ~D[2018-09-09])
      assert is_function(stream)
      assert {:ok, stream} = RecurrenceStream.new("FREQ=DAILY", ~N[2018-09-09 12:30:00])
      assert is_function(stream)
    end

    test "raises ArgumentError when not given a string for rrule" do
      assert_raise ArgumentError, fn -> RecurrenceStream.new(:invalid, ~D[2018-09-09]) end
    end

    test "returns an error when an invalid rrule string is given" do
      assert {:error, :invalid_rrule} = RecurrenceStream.new("INVALID", ~D[2018-09-09])
    end

    test "returns an error when an invalid datetime type is given" do
      assert {:error, :unsupported_datetime_type} = RecurrenceStream.new("FREQ=DAILY", :invalid)
    end

    test "accepts an option for start time" do
      assert {:ok, stream} = RecurrenceStream.new("FREQ=DAILY", ~D[2018-09-09], from: ~D[2019-09-09])
      assert is_function(stream)
    end

    test "accepts an option for end time" do
      assert {:ok, stream} = RecurrenceStream.new("FREQ=DAILY", ~D[2018-09-09], until: ~D[2019-09-09])
      assert is_function(stream)
    end
  end

  describe "Taking occurrences from the stream" do
    setup [:stream]

    @tag rrule: "FREQ=DAILY"
    @tag dtstart: ~D[2018-09-09]
    test "returns date occurrences if dtstart is given as a Date", %{stream: stream} do
      times = Enum.take(stream, 3)

      assert times == [
               ~D[2018-09-09],
               ~D[2018-09-10],
               ~D[2018-09-11]
             ]
    end

    @tag rrule: "FREQ=DAILY"
    @tag dtstart: ~N[2018-09-09 12:30:00]
    test "returns datetime occurrences if dtstart is given as a NaiveDateTime", %{stream: stream} do
      times = Enum.take(stream, 3)

      assert times == [
               ~N[2018-09-09 12:30:00],
               ~N[2018-09-10 12:30:00],
               ~N[2018-09-11 12:30:00]
             ]
    end

    @tag rrule: "FREQ=DAILY;COUNT=3"
    @tag dtstart: ~D[2018-09-09]
    test "finishes the stream when the set of occurrences described by rrule runs out", %{stream: stream} do
      times = Enum.to_list(stream)

      assert times == [
               ~D[2018-09-09],
               ~D[2018-09-10],
               ~D[2018-09-11]
             ]
    end

    @tag rrule: "FREQ=WEEKLY"
    @tag dtstart: ~D[2018-09-09]
    @tag from: ~D[2019-09-09]
    test "respects the configured start time", %{stream: stream} do
      times = Enum.take(stream, 3)

      assert times == [
               ~D[2019-09-15],
               ~D[2019-09-22],
               ~D[2019-09-29]
             ]
    end

    @tag rrule: "FREQ=WEEKLY"
    @tag dtstart: ~D[2018-09-09]
    @tag until: ~D[2018-09-24]
    test "respects the configured end time", %{stream: stream} do
      times = Enum.to_list(stream)

      assert times == [
               ~D[2018-09-09],
               ~D[2018-09-16],
               ~D[2018-09-23]
             ]
    end
  end

  defp stream(context) do
    rrule = context[:rrule]
    dtstart = context[:dtstart]

    opts =
      Enum.reduce(context, [], fn
        {:from, from}, opts -> [{:from, from} | opts]
        {:until, until}, opts -> [{:until, until} | opts]
        {_, _}, opts -> opts
      end)

    {:ok, stream} = RecurrenceStream.new(rrule, dtstart, opts)

    [stream: stream]
  end
end
