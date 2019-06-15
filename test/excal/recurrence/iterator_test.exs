defmodule Excal.Recurrence.IteratorTest do
  use ExUnit.Case, async: true

  alias Excal.Recurrence.Iterator

  doctest Iterator

  describe "Iterator.new/3" do
    test "returns an iterator struct when valid inputs are given" do
      assert {:ok, %Iterator{}} = Iterator.new("FREQ=DAILY", ~D[2018-09-09])
      assert {:ok, %Iterator{}} = Iterator.new("FREQ=DAILY", ~N[2018-09-09 12:30:00])
      assert {:ok, %Iterator{}} = Iterator.new("FREQ=DAILY", DateTime.from_naive!(~N[2018-09-09 12:30:00], "Etc/UTC"))

      assert {:ok, %Iterator{}} =
               Iterator.new("FREQ=DAILY", DateTime.from_naive!(~N[2018-09-09 12:30:00], "America/Los_Angeles"))
    end

    test "raises ArgumentError when not given a string for rrule" do
      assert_raise ArgumentError, fn -> Iterator.new(:invalid, ~D[2018-09-09]) end
    end

    test "returns an error when an invalid rrule string is given" do
      assert {:error, :invalid_rrule} = Iterator.new("INVALID", ~D[2018-09-09])
    end

    test "returns an error when an invalid dtstart is given" do
      assert {:error, :unsupported_datetime_type} = Iterator.new("FREQ=DAILY", :invalid)
    end
  end

  describe "Iterator.set_start/2" do
    setup [:iterator]

    test "returns :ok if the start time is valid", %{iterator: iterator} do
      assert {:ok, %Iterator{}} = Iterator.set_start(iterator, ~D[2019-09-09])
    end

    test "returns an error when the start type doesn't match the iterator's dtstart type", %{iterator: iterator} do
      assert {:error, :datetime_type_mismatch} = Iterator.set_start(iterator, ~N[2018-09-09 12:30:00])

      assert {:error, :datetime_type_mismatch} =
               Iterator.set_start(iterator, DateTime.from_naive!(~N[2018-09-09 12:30:00], "Etc/UTC"))

      assert {:error, :datetime_type_mismatch} =
               Iterator.set_start(iterator, DateTime.from_naive!(~N[2018-09-09 12:30:00], "America/Los_Angeles"))
    end

    @tag dtstart: DateTime.from_naive!(~N[2018-09-09 12:30:00], "America/Los_Angeles")
    test "returns an error when the start time zone doesn't match the iterator's dtstart time zone", %{
      iterator: iterator
    } do
      assert {:error, :datetime_type_mismatch} =
               Iterator.set_start(iterator, DateTime.from_naive!(~N[2019-09-09 12:30:00], "America/New_York"))
    end

    test "raises if not given an iterator" do
      assert_raise ArgumentError, fn -> Iterator.set_start(:foo, ~N[2018-09-09 12:30:00]) end
    end
  end

  describe "Iterator.set_end/2" do
    setup [:iterator]

    test "returns :ok if the end time is valid", %{iterator: iterator} do
      assert {:ok, %Iterator{}} = Iterator.set_end(iterator, ~D[2019-09-09])
    end

    test "returns an error when the end type doesn't match the iterator's dtstart type", %{iterator: iterator} do
      assert {:error, :datetime_type_mismatch} = Iterator.set_end(iterator, ~N[2018-09-09 12:30:00])

      assert {:error, :datetime_type_mismatch} =
               Iterator.set_end(iterator, DateTime.from_naive!(~N[2018-09-09 12:30:00], "Etc/UTC"))

      assert {:error, :datetime_type_mismatch} =
               Iterator.set_end(iterator, DateTime.from_naive!(~N[2018-09-09 12:30:00], "America/Los_Angeles"))
    end

    @tag dtstart: DateTime.from_naive!(~N[2018-09-09 12:30:00], "America/Los_Angeles")
    test "returns an error when the end time zone doesn't match the iterator's dtstart time zone", %{
      iterator: iterator
    } do
      assert {:error, :datetime_type_mismatch} =
               Iterator.set_end(iterator, DateTime.from_naive!(~N[2019-09-09 12:30:00], "America/New_York"))
    end

    test "raises if not given an iterator" do
      assert_raise ArgumentError, fn -> Iterator.set_end(:foo, ~N[2018-09-09 12:30:00]) end
    end
  end

  describe "Iterator.next/1" do
    setup [:iterator]

    test "returns the next occurrence of the given iterator", %{iterator: iterator} do
      assert {~D[2018-09-09], %Iterator{}} = Iterator.next(iterator)
    end

    @tag dtstart: ~N[2018-09-09 12:30:00]
    test "returns datetimes when iterator was initialized with datetime dtstart", %{iterator: iterator} do
      assert {~N[2018-09-09 12:30:00], %Iterator{}} = Iterator.next(iterator)
    end

    @tag rrule: "FREQ=DAILY;COUNT=2"
    test "return nil once the iterator has reached the end of the set described by the rrule", %{iterator: iterator} do
      assert {~D[2018-09-09], %Iterator{} = iterator} = Iterator.next(iterator)
      assert {~D[2018-09-10], %Iterator{} = iterator} = Iterator.next(iterator)
      assert {nil, %Iterator{}} = Iterator.next(iterator)
    end

    @tag start: ~D[2019-09-09]
    test "respects the given start time", %{iterator: iterator} do
      assert {~D[2019-09-09], %Iterator{}} = Iterator.next(iterator)
    end

    @tag end: ~D[2018-09-11]
    test "respects the given end time", %{iterator: iterator} do
      assert {~D[2018-09-09], %Iterator{} = iterator} = Iterator.next(iterator)
      assert {~D[2018-09-10], %Iterator{} = iterator} = Iterator.next(iterator)
      assert {nil, %Iterator{}} = Iterator.next(iterator)
    end
  end

  defp iterator(context) do
    rrule = Map.get(context, :rrule, "FREQ=DAILY")
    dtstart = Map.get(context, :dtstart, ~D[2018-09-09])

    {:ok, iterator} = Iterator.new(rrule, dtstart)
    iterator = add_start(Map.get(context, :start), iterator)
    iterator = add_end(Map.get(context, :end), iterator)

    [iterator: iterator]
  end

  defp add_start(nil, iterator), do: iterator

  defp add_start(start_time, iterator) do
    {:ok, iterator} = Iterator.set_start(iterator, start_time)
    iterator
  end

  defp add_end(nil, iterator), do: iterator

  defp add_end(end_time, iterator) do
    {:ok, iterator} = Iterator.set_end(iterator, end_time)
    iterator
  end
end
