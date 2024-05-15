import Mox

defmock(ExAthena.ClockMock, for: ExAthena.Clock)
defmock(ExAthenaEventsMock, for: ExAthenaEvents.Behaviour)
defmock(ExAthenaLoggerMock, for: ExAthenaLogger)

defmodule FakeExAthenaLogger do
  @moduledoc false
  @behaviour ExAthenaLogger

  @impl true
  def handle_event(_, _, _, _), do: :ok
end

defmodule FakeExAthenaEvents do
  @moduledoc false
  @behaviour ExAthenaEvents.Behaviour

  def user_authentication_requested(_), do: :ok
  def user_authentication_accepted(_, _), do: :ok
  def user_authentication_rejected(_, _), do: :ok
end
