defmodule Excal.Recurrence.Stream do
  @moduledoc """
  Generates Elixir streams from iCalendar recurrence rules (RRULE).

  This is the most idiomatic way of interacting with iCalendar recurrence rules in Elixir. The streams created here act
  like any other Elixir stream would act.
  """

  alias Excal.Recurrence.Iterator

  @typedoc """
  Valid options for `new/3`.
  """
  @type option :: {:from, Excal.date_or_datetime()} | {:until, Excal.date_or_datetime()}

  @doc """
  Creates a stream of date or datetime instances from the given recurrence rule string and schedule start time.

  It's also possible to set the start and end time of the stream using the `:from` and `:until` options.

  ## Options

    * `:from` - specifies the start date or datetime of the stream.
    * `:until` - specifies the end date or datetime of the stream.

  ## Examples

  An infinite stream of `Date` structs for every Monday, Wednesday and Friday:

        iex> {:ok, stream} = Stream.new("FREQ=WEEKLY;BYDAY=MO,WE,FR", ~D[2019-01-01])
        ...> Enum.take(stream, 5)
        [
          ~D[2019-01-02],
          ~D[2019-01-04],
          ~D[2019-01-07],
          ~D[2019-01-09],
          ~D[2019-01-11]
        ]

  A finite stream of `NaiveDateTime` using the `:from` and `:until` options:

        iex> opts = [from: ~N[2020-01-01 10:00:00], until: ~N[2020-06-01 10:00:00]]
        ...> {:ok, stream} = Stream.new("FREQ=MONTHLY;BYMONTHDAY=1", ~N[2019-01-01 10:00:00], opts)
        ...> Enum.to_list(stream)
        [
          ~N[2020-01-01 10:00:00],
          ~N[2020-02-01 10:00:00],
          ~N[2020-03-01 10:00:00],
          ~N[2020-04-01 10:00:00],
          ~N[2020-05-01 10:00:00]
        ]
  """
  @spec new(String.t(), Excal.date_or_datetime(), [option()]) ::
          {:ok, Enumerable.t()} | {:error, Iterator.initialization_error() | Iterator.iterator_start_error()}
  def new(rrule, dtstart, opts \\ []) do
    # The below call to make_stream will not return any errors until the stream is used,
    # so we initialize an iterator first to ensure it can be, to return any possible errors.
    # This iterator is not actually used though.
    with {:ok, _} <- make_iterator(rrule, dtstart, opts) do
      {:ok, make_stream(rrule, dtstart, opts)}
    end
  end

  defp make_iterator(rrule, dtstart, opts) do
    with {:ok, iterator} <- Iterator.new(rrule, dtstart) do
      process_options(iterator, opts)
    end
  end

  defp process_options(iterator, []), do: {:ok, iterator}

  defp process_options(iterator, [{:from, time} | rest]) do
    with {:ok, iterator} <- Iterator.set_start(iterator, time) do
      process_options(iterator, rest)
    end
  end

  defp process_options(iterator, [{:until, time} | rest]) do
    with {:ok, iterator} <- Iterator.set_end(iterator, time) do
      process_options(iterator, rest)
    end
  end

  defp make_stream(rrule, dtstart, opts) do
    Elixir.Stream.resource(
      fn ->
        {:ok, iterator} = make_iterator(rrule, dtstart, opts)
        iterator
      end,
      fn iterator ->
        case Iterator.next(iterator) do
          {nil, iterator} -> {:halt, iterator}
          {occurrence, iterator} -> {[occurrence], iterator}
        end
      end,
      fn _ -> nil end
    )
  end
end
