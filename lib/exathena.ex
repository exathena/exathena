defmodule ExAthena do
  @moduledoc false

  @clock Application.compile_env(:exathena, :clock_module, ExAthena.Clock.Timex)

  @doc """
  Returns the actual datetime with time zone applied.

  ## Examples

      iex> ExAthena.clock()
      ~U[2022-01-01 03:00:00Z]

      iex> ExAthena.clock(:utc)
      ~U[2022-01-01 03:00:00Z]

      iex> ExAthena.clock("America/Sao_Paulo")
      ~U[2022-01-01 00:00:00Z]

  """
  @spec now(String.t() | :utc) :: DateTime.t()
  def now(tz \\ :utc), do: @clock.now(tz)
end
