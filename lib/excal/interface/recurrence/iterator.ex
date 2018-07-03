defmodule Excal.Interface.Recurrence.Iterator do
  @moduledoc false

  @on_load :load_nifs

  def load_nifs, do: :erlang.load_nif('./priv/recurrence/iterator', 0)

  def new(_rrule, _dtstart), do: raise("NIF new/2 not implemented")
  def set_start(_iterator, _start), do: raise("NIF set_start/2 not implemented")
  def set_end(_iterator, _end), do: raise("NIF set_end/2 not implemented")
  def next(_iterator), do: raise("NIF next/1 not implemented")
end
