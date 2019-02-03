defmodule Excal.Recurrence.Iterator do
  @moduledoc """
  Elixir wrapper around a libical recurrence iterator.

  The iterator is fundamentally a mutable resource, so it acts more like a stateful reference, rather than an immutable
  data structure. To create one, you will need a iCalendar recurrence rule string and a start date or datetime.
  """

  alias __MODULE__
  alias Excal.Interface.Recurrence.Iterator, as: Interface

  @enforce_keys [:iterator, :type, :rrule, :dtstart]
  defstruct iterator: nil, type: nil, rrule: nil, dtstart: nil, from: nil, until: nil, finished: false

  @typedoc """
  A struct that represents a recurrence iterator. Consider all the fields to be internal implementation detail at this
  time, as they may change without notice.
  """
  @type t :: %Iterator{
          iterator: reference(),
          type: Date | NaiveDateTime,
          rrule: String.t(),
          dtstart: Excal.date_or_datetime(),
          from: nil | Excal.date_or_datetime(),
          until: nil | Excal.date_or_datetime(),
          finished: boolean()
        }

  @typedoc """
  Possible errors returned from iterator initialization.
  """
  @type initialization_error :: :unsupported_datetime_type | Interface.initialization_error()

  @typedoc """
  Possible errors returned from setting the start date or datetime of an iterator.
  """
  @type iterator_start_error :: :unsupported_datetime_type | :datetime_type_mismatch | Interface.iterator_start_error()

  @doc """
  Creates a new recurrence iterator from an iCalendar recurrence rule (RRULE) string and a start date or datetime.

  ## Examples

  A daily schedule starting on January 1st 2019:

        iex> {:ok, iter} = Iterator.new("FREQ=DAILY", ~D[2019-01-01])
        ...> {_occurrence, iter} = Iterator.next(iter)
        ...> {_occurrence, iter} = Iterator.next(iter)
        ...> {occurrence, _iter} = Iterator.next(iter)
        ...> occurrence
        ~D[2019-01-03]

  A bi-weekly schedule every Monday, Wednesday and Friday:

        iex> {:ok, iter} = Iterator.new("FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR", ~D[2019-01-01])
        ...> {occurrence, _iter} = Iterator.next(iter)
        ...> occurrence
        ~D[2019-01-07]
  """
  @spec new(String.t(), Excal.date_or_datetime()) :: {:ok, t()} | {:error, initialization_error()}
  def new(rrule, date_or_datetime) do
    with {:ok, type, dtstart} <- to_ical_time_string(date_or_datetime),
         {:ok, iterator} <- Interface.new(rrule, dtstart) do
      {:ok, %Iterator{iterator: iterator, type: type, rrule: rrule, dtstart: date_or_datetime}}
    end
  end

  @doc """
  Sets the start date or datetime for an existing iterator.

  The iterator's start time is not the same thing as the schedule's start time. At creation time, an iterator is given a
  recurrence rule string and a schedule start date or datetime, but the iterator's start can be some time farther in the
  future than the schedules start time.

  This can also be used to reset an existing iterator to a new starting time.

  ## Example

  Consider: an RRULE for Friday on every 3rd week starting January 1st 2016 might look like this:

        iex> {:ok, iter} = Iterator.new("FREQ=WEEKLY;INTERVAL=3", ~D[2016-01-01])
        ...> {next_occurrence, _iter} = Iterator.next(iter)
        ...> next_occurrence
        ~D[2016-01-01]

  ...but if you only cared about the instances starting in 2019, you can't change the start date because that would
  affect the cadence of the "every 3rd week" part of the schedule. Instead, just tell the iterator to skip ahead until
  2019:

        iex> {:ok, iter} = Iterator.new("FREQ=WEEKLY;INTERVAL=3", ~D[2016-01-01])
        ...> {:ok, iter} = Iterator.set_start(iter, ~D[2019-01-01])
        ...> {next_occurrence, _iter} = Iterator.next(iter)
        ...> next_occurrence
        ~D[2019-01-18]
  """
  @spec set_start(t(), Excal.date_or_datetime()) :: {:ok, t()} | {:error, iterator_start_error()}
  def set_start(%Iterator{iterator: iterator_ref, type: type} = iterator, %type{} = date_or_datetime) do
    with {:ok, _, time_string} <- to_ical_time_string(date_or_datetime),
         :ok <- Interface.set_start(iterator_ref, time_string) do
      {:ok, %{iterator | from: date_or_datetime}}
    end
  end

  def set_start(%Iterator{}, _), do: {:error, :datetime_type_mismatch}
  def set_start(iterator, _), do: raise(ArgumentError, "invalid iterator: #{inspect(iterator)}")

  @doc """
  Sets the end date or datetime for an existing iterator.

  Once an end time is set for an iterator, the iterator will return `nil` once it has reached the specified end.

  ## Example

        iex> {:ok, iter} = Iterator.new("FREQ=DAILY", ~D[2019-01-01])
        ...> {:ok, iter} = Iterator.set_end(iter, ~D[2019-01-03])
        ...> {_occurrence, iter} = Iterator.next(iter)
        ...> {_occurrence, iter} = Iterator.next(iter)
        ...> {occurrence, _iter} = Iterator.next(iter)
        ...> occurrence
        nil

  """
  @spec set_end(t(), Excal.date_or_datetime()) :: {:ok, t()} | {:error, :datetime_type_mismatch}
  def set_end(%Iterator{type: type} = iterator, %type{} = date_or_datetime) do
    {:ok, %{iterator | until: date_or_datetime}}
  end

  def set_end(%Iterator{}, _), do: {:error, :datetime_type_mismatch}
  def set_end(iterator, _), do: raise(ArgumentError, "invalid iterator: #{inspect(iterator)}")

  @doc """
  Returns the next date or datetime occurrence of an existing iterator.

  If the iterator has reached the end of the set described by the RRULE, or has reached the end time specified by
  `set_end/2`, it will return `nil`.

  ## Example

        iex> {:ok, iter} = Iterator.new("FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR", ~D[2019-01-01])
        ...> {occurrence, _iter} = Iterator.next(iter)
        ...> occurrence
        ~D[2019-01-07]
  """
  @spec next(t()) :: {Excal.date_or_datetime(), t()} | {nil, t()}
  def next(%Iterator{finished: true} = iterator), do: {nil, iterator}

  def next(%Iterator{iterator: iterator_ref, type: type, until: until} = iterator) do
    occurrence = iterator_ref |> Interface.next() |> from_tuple(type)

    cond do
      is_nil(occurrence) ->
        {nil, %{iterator | finished: true}}

      is_nil(until) ->
        {occurrence, iterator}

      type.compare(occurrence, until) == :lt ->
        {occurrence, iterator}

      true ->
        {nil, %{iterator | finished: true}}
    end
  end

  defp to_ical_time_string(%Date{} = date), do: {:ok, Date, Date.to_iso8601(date, :basic)}

  defp to_ical_time_string(%NaiveDateTime{} = datetime),
    do: {:ok, NaiveDateTime, NaiveDateTime.to_iso8601(datetime, :basic)}

  defp to_ical_time_string(_), do: {:error, :unsupported_datetime_type}

  # NOTE:
  # Native Elixir Date and NaiveDateTime are heavy to initialize with `new` or `from_erl!` because it checks validity.
  # We're bypassing the validity check here, assuming that libical is giving us valid dates and times.

  defp from_tuple(nil, _), do: nil

  defp from_tuple({year, month, day}, Date),
    do: %Date{year: year, month: month, day: day, calendar: Calendar.ISO}

  defp from_tuple({{year, month, day}, {hour, minute, second}}, NaiveDateTime),
    do: %NaiveDateTime{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      calendar: Calendar.ISO
    }
end
