defmodule Excal.Interface.Recurrence.Iterator do
  @moduledoc """
  TODO: docs
  """

  @on_load :load_nifs

  @type initialization_error :: :invalid_dtstart | :invalid_rrule | :bad_iterator
  @type iterator_start_error :: :invalid_start | :start_invalid_for_rule

  @doc false
  def load_nifs, do: :erlang.load_nif('./priv/recurrence/iterator', 0)

  @doc """
  TODO: docs
  """
  @spec new(String.t(), String.t()) ::
          {:ok, reference()} | {:error, initialization_error()}
  def new(_rrule, _dtstart), do: :erlang.nif_error("NIF new/2 not implemented")

  @doc """
  TODO: docs
  """
  @spec set_start(reference(), String.t()) :: :ok | {:error, iterator_start_error()}
  def set_start(_iterator, _start), do: :erlang.nif_error("NIF set_start/2 not implemented")

  @doc """
  TODO: docs
  """
  @spec next(reference()) :: nil | :calendar.date() | :calendar.datetime()
  def next(_iterator), do: :erlang.nif_error("NIF next/1 not implemented")
end
