defmodule Excal.Interface.Recurrence.IteratorTest do
  use ExUnit.Case, async: true

  alias Excal.Interface.Recurrence.Iterator

  describe "Iterator.new/3" do
    test "returns an iterator reference when valid inputs are given" do
      assert {:ok, iterator} = Iterator.new("FREQ=DAILY", "20180909")
      assert is_reference(iterator)
      assert {:ok, iterator} = Iterator.new("FREQ=DAILY", "20180909T123000")
      assert is_reference(iterator)
    end

    test "raises ArgumentError when not given a string for rrule" do
      assert_raise ArgumentError, fn -> Iterator.new(:invalid, "20180909T123000") end
    end

    test "raises ArgumentError when not given a string for dtstart" do
      assert_raise ArgumentError, fn -> Iterator.new("FREQ=DAILY", :invalid) end
    end

    test "returns an error when an invalid rrule string is given" do
      assert {:error, :invalid_rrule} = Iterator.new("INVALID", "20180909T123000")
    end

    test "returns an error when an invalid dtstart string is given" do
      assert {:error, :invalid_dtstart} = Iterator.new("FREQ=DAILY", "INVALID")
    end
  end

  describe "Iterator.set_start/2" do
    setup [:iterator]

    test "returns :ok if the start time is valid", %{iterator: iterator} do
      assert :ok = Iterator.set_start(iterator, "20190909")
    end

    test "raises ArgumentError when not given a string for start", %{iterator: iterator} do
      assert_raise ArgumentError, fn -> Iterator.set_start(iterator, :invalid) end
    end

    test "raises ArgumentError when not given a valid iterator" do
      assert_raise ArgumentError, fn -> Iterator.set_start(:invalid, "20190909") end
    end

    @tag rrule: "FREQ=DAILY;COUNT=2"
    test "returns an error when setting start for rrule that has a COUNT", %{iterator: iterator} do
      assert {:error, :start_invalid_for_rule} = Iterator.set_start(iterator, "20190909")
    end
  end

  describe "Iterator.set_end/2" do
    setup [:iterator]

    test "returns :ok if the end time is valid", %{iterator: iterator} do
      assert :ok = Iterator.set_end(iterator, "20190909")
    end

    test "raises ArgumentError when not given a string for end", %{iterator: iterator} do
      assert_raise ArgumentError, fn -> Iterator.set_end(iterator, :invalid) end
    end

    test "raises ArgumentError when not given a valid iterator" do
      assert_raise ArgumentError, fn -> Iterator.set_end(:invalid, "20190909") end
    end
  end

  describe "Iterator.next/1" do
    setup [:iterator]

    test "returns the next occurrence of the given iterator", %{iterator: iterator} do
      assert {2018, 9, 9} = Iterator.next(iterator)
    end

    @tag dtstart: "20180909T123000"
    test "returns datetimes when iterator was initialized with datetime dtstart", %{iterator: iterator} do
      assert {{2018, 9, 9}, {12, 30, 0}} = Iterator.next(iterator)
    end

    @tag rrule: "FREQ=DAILY;COUNT=2"
    test "return nil once the iterator has reached the end of the set described by the rrule", %{iterator: iterator} do
      assert {2018, 9, 9} = Iterator.next(iterator)
      assert {2018, 9, 10} = Iterator.next(iterator)
      assert is_nil(Iterator.next(iterator))
    end

    @tag start: "20190909"
    test "respects the given start time", %{iterator: iterator} do
      assert {2019, 9, 9} = Iterator.next(iterator)
    end

    @tag end: "20180911"
    test "respects the given end time", %{iterator: iterator} do
      assert {2018, 9, 9} = Iterator.next(iterator)
      assert {2018, 9, 10} = Iterator.next(iterator)
      assert is_nil(Iterator.next(iterator))
    end

    test "raises ArgumentError when not given an iterator" do
      assert_raise ArgumentError, fn -> Iterator.next(:invalid) end
    end
  end

  defp iterator(context) do
    rrule = Map.get(context, :rrule, "FREQ=DAILY")
    dtstart = Map.get(context, :dtstart, "20180909")

    {:ok, iterator} = Iterator.new(rrule, dtstart)

    if start_time = Map.get(context, :start) do
      Iterator.set_start(iterator, start_time)
    end

    if end_time = Map.get(context, :end) do
      Iterator.set_end(iterator, end_time)
    end

    [iterator: iterator]
  end
end
