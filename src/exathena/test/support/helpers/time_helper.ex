defmodule ExAthena.TimeHelper do
  @moduledoc false

  @doc false
  @spec freeze_time() :: atom()
  def freeze_time, do: travel_to(Timex.now())

  @doc false
  @spec travel_to(Date.t() | DateTime.t()) :: atom()
  def travel_to(date_or_datetime, times \\ 1) do
    Mox.expect(ExAthena.ClockMock, :now, times, fn _ -> date_or_datetime end)
  end
end
