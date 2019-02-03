defmodule Excal.Recurrence.Stream do
  @moduledoc """
  Generates Elixir streams from iCalendar recurrence rules (RRULE).

  TODO: more docs
  """

  alias Excal.Recurrence.Iterator

  @type option :: {:from, Excal.date_or_datetime()} | {:until, Excal.date_or_datetime()}
  @type options :: [option()]

  @doc """
  TODO: docs
  """
  @spec new(String.t(), Excal.date_or_datetime(), options()) ::
          {:ok, Enumerable.t()} | {:error, Iterator.initialization_error()}
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
