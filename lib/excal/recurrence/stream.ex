defmodule Excal.Recurrence.Stream do
  @moduledoc """
  Generates Elixir streams from icalendar rrules.
  """

  alias Excal.Recurrence.Iterator

  def new(rrule, dtstart, opts \\ []) do
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
