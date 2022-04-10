defmodule ExAthenaLogger.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ExAthena.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  @port 5489
  @options [:binary, active: false]

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ExAthenaLogger.DataCase
      import ExAthena.TimeHelper
      import ExUnit.CaptureLog
      import Mox

      alias ExAthena.Factory

      setup :verify_on_exit!
    end
  end

  setup tags do
    {:ok, server} = :gen_tcp.listen(@port, @options)
    {:ok, socket} = :gen_tcp.connect('localhost', @port, @options)

    pid_main = Ecto.Adapters.SQL.Sandbox.start_owner!(ExAthena.Repo, shared: not tags[:async])

    on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid_main)
      :ok = :gen_tcp.close(server)
      :ok = :gen_tcp.close(socket)
    end)

    {:ok, socket: socket}
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  Assert changeset
  """
  defmacro assert_changeset(right) do
    left =
      quote do
        %Ecto.Changeset{valid?: true}
      end

    __match__(left, right, "Assert changeset failed")
  end

  @doc """
  Refute changeset
  """
  defmacro refute_changeset(right) do
    left =
      quote do
        %Ecto.Changeset{valid?: false}
      end

    __match__(left, right, "Refute changeset failed")
  end

  defp __match__(left, right, message) do
    code =
      quote do
        assert unquote(left) = unquote(right)
      end

    match? = assert left = right

    quote location: :keep do
      right = unquote(right)
      left = unquote(Macro.escape(left))

      ExUnit.Assertions.assert(unquote(match?),
        right: right,
        left: left,
        expr: unquote(code),
        message: unquote(message)
      )

      right
    end
  end
end
