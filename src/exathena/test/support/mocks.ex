import Mox

defmock(ExAthena.ClockMock, for: ExAthena.Clock)
defmock(ExAthenaLoggerMock, for: ExAthenaLogger)

defmodule FakeExAthenaLogger do
  @moduledoc false
  @behaviour ExAthenaLogger

  @impl true
  def handle_event(_, _, _, _), do: :ok
end