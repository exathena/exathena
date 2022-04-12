defmodule ExAthena.SocketCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  @port 5489
  @options [:binary, active: false]

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
    {:ok, server} = :gen_tcp.listen(@port, @options)
    {:ok, socket} = :gen_tcp.connect('localhost', @port, @options)

    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(ExAthena.Repo, shared: not tags[:async])

    on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
      :ok = :gen_tcp.close(server)
      :ok = :gen_tcp.close(socket)
    end)

    {:ok, socket: socket}
  end
end
