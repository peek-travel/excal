defmodule Excal do
  @moduledoc """
  Excal provides basic Elixir bindings to libical, the reference implementation of the iCalendar spec written in C.

  There are currently two possible ways to use Excal:

  * `Excal.Recurrence.Iterator`
    * A simple Elixir wrapper around a libical recurrence iterator.
  * `Excal.Recurrence.Stream`
    * An Elixir `Stream` wrapper for the above iterator.

  Refer to either of the two modules above for documentation on how to use them.
  """

  @typedoc """
  Recurrence iterators and streams can operate using either Date or NaiveDateTime structs.
  """
  @type date_or_datetime :: Date.t() | NaiveDateTime.t()
end
