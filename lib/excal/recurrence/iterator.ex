defmodule Excal.Recurrence.Iterator do
  @moduledoc """
  Elixir wrapper around an icalendar recurrence iterator.

  TODO: more docs
  """

  alias Excal.Interface.Recurrence.Iterator, as: Interface

  @enforce_keys [:iterator, :type, :rrule, :dtstart]
  defstruct iterator: nil, type: nil, rrule: nil, dtstart: nil, from: nil, until: nil, finished: false

  @type t :: %__MODULE__{
          iterator: reference(),
          type: Date | NaiveDateTime,
          rrule: String.t(),
          dtstart: Excal.date_or_datetime(),
          from: nil | Excal.date_or_datetime(),
          until: nil | Excal.date_or_datetime(),
          finished: boolean()
        }

  @type initialization_error :: :unsupported_datetime_type | Interface.initialization_error()
  @type iterator_start_error :: :unsupported_datetime_type | :datetime_type_mismatch | Interface.iterator_start_error()

  @doc """
  TODO: docs
  """
  @spec new(String.t(), Excal.date_or_datetime()) :: {:ok, t()} | {:error, initialization_error()}
  def new(rrule, date_or_datetime) do
    with {:ok, type, dtstart} <- to_ical_time_string(date_or_datetime),
         {:ok, iterator} <- Interface.new(rrule, dtstart) do
      {:ok, %__MODULE__{iterator: iterator, type: type, rrule: rrule, dtstart: date_or_datetime}}
    end
  end

  @doc """
  TODO: docs
  """
  @spec set_start(t(), Excal.date_or_datetime()) :: {:ok, t()} | {:error, iterator_start_error()}
  def set_start(%__MODULE__{iterator: iterator_ref, type: type} = iterator, %type{} = date_or_datetime) do
    with {:ok, _, time_string} <- to_ical_time_string(date_or_datetime),
         :ok <- Interface.set_start(iterator_ref, time_string) do
      {:ok, %{iterator | from: date_or_datetime}}
    end
  end

  def set_start(_, _), do: {:error, :datetime_type_mismatch}

  @doc """
  TODO: docs
  """
  @spec set_end(t(), Excal.date_or_datetime()) :: {:ok, t()} | {:error, :datetime_type_mismatch}
  def set_end(%__MODULE__{type: type} = iterator, %type{} = date_or_datetime) do
    {:ok, %{iterator | until: date_or_datetime}}
  end

  def set_end(_, _), do: {:error, :datetime_type_mismatch}

  @doc """
  TODO: docs
  """
  @spec next(t()) :: {Excal.date_or_datetime(), t()} | {nil, t()}
  def next(%__MODULE__{finished: true} = iterator), do: {nil, iterator}

  def next(%__MODULE__{iterator: iterator_ref, type: type, until: until} = iterator) do
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
