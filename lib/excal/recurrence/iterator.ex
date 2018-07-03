defmodule Excal.Recurrence.Iterator do
  @moduledoc """
  Elixir wrapper around an icalendar recurrence iterator.
  """

  alias Excal.Interface.Recurrence.Iterator, as: Interface

  @enforce_keys [:iterator, :type, :rrule, :dtstart]
  defstruct iterator: nil, type: nil, rrule: nil, dtstart: nil

  def new(rrule, date_or_datetime) do
    with {:ok, type, dtstart} <- to_ical_time_string(date_or_datetime),
         {:ok, iterator} <- Interface.new(rrule, dtstart) do
      {:ok, %__MODULE__{iterator: iterator, type: type, rrule: rrule, dtstart: date_or_datetime}}
    end
  end

  def set_start(%__MODULE__{iterator: iterator_ref, type: type} = iterator, %type{} = date_or_datetime) do
    with {:ok, _, time_string} <- to_ical_time_string(date_or_datetime),
         :ok <- Interface.set_start(iterator_ref, time_string) do
      {:ok, iterator}
    end
  end

  def set_start(_, _), do: {:error, :datetime_type_mismatch}

  def set_end(%__MODULE__{iterator: iterator_ref, type: type} = iterator, %type{} = date_or_datetime) do
    with {:ok, _, time_string} <- to_ical_time_string(date_or_datetime),
         :ok <- Interface.set_end(iterator_ref, time_string) do
      {:ok, iterator}
    end
  end

  def set_end(_, _), do: {:error, :datetime_type_mismatch}

  def next(%__MODULE__{iterator: iterator_ref, type: type} = iterator) do
    occurrence = Interface.next(iterator_ref)
    {from_tuple(occurrence, type), iterator}
  end

  defp to_ical_time_string(%Date{} = date), do: {:ok, Date, Date.to_iso8601(date, :basic)}

  defp to_ical_time_string(%NaiveDateTime{} = datetime),
    do: {:ok, NaiveDateTime, NaiveDateTime.to_iso8601(datetime, :basic)}

  defp to_ical_time_string(_), do: {:error, :unsupported_datetime_type}

  defp from_tuple(nil, _), do: nil
  defp from_tuple({year, month, day}, Date), do: %Date{year: year, month: month, day: day}

  defp from_tuple({{year, month, day}, {hour, minute, second}}, NaiveDateTime),
    do: %NaiveDateTime{year: year, month: month, day: day, hour: hour, minute: minute, second: second}
end
