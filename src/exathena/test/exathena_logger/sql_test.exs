defmodule ExAthenaLogger.SqlTest do
  use ExAthenaLogger.DataCase, async: true

  alias ExAthenaLogger.Sql
  alias ExAthenaLogger.Sql.AuthenticationLog

  setup do
    {:ok, socket: join_public_channel(ExAthenaWeb.LoginChannel, "login")}
  end

  describe "[:exathena, :authentication, :log]" do
    @describetag event: ~w(exathena authentication log)a

    test "inserts the requested authentication log", %{
      event: event,
      socket: socket = %{join_ref: join_ref}
    } do
      meta = %{socket: socket, type: :request}

      assert {:ok, %AuthenticationLog{join_ref: ^join_ref}} =
               Sql.handle_event(event, %{}, meta, [])
    end

    test "inserts the accepted authentication log", %{event: event, socket: socket} do
      user = Factory.insert(:user)
      meta = %{socket: socket, user: user, result: :accepted}

      user_id = user.id

      assert {:ok, %AuthenticationLog{user_id: ^user_id}} = Sql.handle_event(event, %{}, meta, [])
    end

    test "inserts the rejected authentication log", %{
      event: event,
      socket: socket = %{join_ref: join_ref}
    } do
      meta = %{socket: socket, result: :invalid_credentials}

      assert {:ok, %AuthenticationLog{join_ref: ^join_ref}} =
               Sql.handle_event(event, %{}, meta, [])
    end

    test "inserts the user banned rejected authentication log", %{event: event, socket: socket} do
      user = Factory.insert(:user)
      banned_until = Factory.insert(:ban, user: user).banned_until
      meta = %{socket: socket, user: user, banned_until: banned_until, result: :user_banned}

      user_id = user.id

      assert {:ok, %AuthenticationLog{user_id: ^user_id}} = Sql.handle_event(event, %{}, meta, [])
    end
  end
end
