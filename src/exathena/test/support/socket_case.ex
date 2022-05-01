defmodule ExAthena.SocketCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  @port 6900
  @options [:binary, active: false, reuseaddr: true, keepalive: true]

  using do
    quote do
      alias ExAthena.Repo

      import Assertions
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ExAthena.DataCase
      import ExAthena.Factory
      import ExAthena.TimeHelper
      import Mox

      setup :verify_on_exit!
    end
  end

  setup tags do
    start_supervised!(ExAthena.Config)
    start_supervised!(ExAthenaMmo.Server)

    {:ok, socket} = :gen_tcp.connect('127.0.0.1', @port, @options)

    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(ExAthena.Repo, shared: not tags[:async])

    on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
      :ok = :gen_tcp.close(socket)
    end)

    {:ok, socket: socket}
  end
end
