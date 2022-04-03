defmodule ExAthena.Clock do
  @moduledoc """
  The clock behaviour.
  """

  @doc """
  Returns the actual datetime with time zone.
  """
  @callback now(String.t() | :utc) :: DateTime.t()
end

defmodule ExAthena.Clock.Timex do
  @moduledoc """
  The real clock implementation with `timex` library.
  """
  @behaviour ExAthena.Clock

  @impl true
  def now(tz), do: Timex.now(tz)
end
