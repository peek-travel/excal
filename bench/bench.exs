defmodule Excal.Benchmarks do
  def test_daily_date do
    {:ok, stream} = Excal.Recurrence.Stream.new("FREQ=DAILY", ~D[2018-09-09])
    Enum.take(stream, 1000)
  end

  def test_daily_datetime do
    {:ok, stream} = Excal.Recurrence.Stream.new("FREQ=DAILY", ~N[2018-09-09 12:30:00])
    Enum.take(stream, 1000)
  end

  def test_weekly_date do
    {:ok, stream} = Excal.Recurrence.Stream.new("FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR", ~D[2018-09-09])
    Enum.take(stream, 1000)
  end

  def test_weekly_datetime do
    {:ok, stream} =
      Excal.Recurrence.Stream.new(
        "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;BYHOUR=12,14;BYMINUTE=0,30",
        ~N[2018-09-09 12:30:00]
      )

    Enum.take(stream, 1000)
  end
end

alias Excal.Benchmarks

Benchee.run(
  %{
    "test_daily_date" => fn -> Benchmarks.test_daily_date() end,
    "test_daily_datetime" => fn -> Benchmarks.test_daily_datetime() end,
    "test_weekly_date" => fn -> Benchmarks.test_weekly_date() end,
    "test_weekly_datetime" => fn -> Benchmarks.test_weekly_datetime() end
  },
  memory_time: 2
)
