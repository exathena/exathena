defmodule ExAthenaLogger.ConsoleTest do
  use ExAthenaLogger.DataCase
  @moduletag capture_log: true

  alias ExAthenaLogger.Console

  @measurements %{duration_ms: 12_345}
  @config []

  setup do
    {:ok, socket: join_public_channel(ExAthenaWeb.LoginChannel, "login")}
  end

  describe "[:exathena, :authentication, :log]" do
    @describetag event: ~w(exathena authentication log)a

    test "logs the requested authentication", %{event: event, socket: socket} do
      meta = %{socket: socket, type: :request}
      expected_message = "Received request authentication from ip 200.120.10.67"

      assert capture_log(log_func(event, meta)) =~ expected_message
    end

    test "logs the accepted authentication", %{event: event, socket: socket} do
      user = Factory.insert(:user)
      meta = %{socket: socket, user: user, result: :accepted}
      expected_message = "Connection accepted from ip 200.120.10.67 associated to user #{user.id}"

      assert capture_log(log_func(event, meta)) =~ expected_message
    end

    test "logs the rejected authentication", %{event: event, socket: socket} do
      meta = %{socket: socket, result: :invalid_credentials}
      expected_message = "Connection refused from ip 200.120.10.67 due to invalid credentials"

      assert capture_log(log_func(event, meta)) =~ expected_message
    end

    test "logs the rejected authentication due to user is banned", %{
      event: event,
      socket: socket = %{id: id}
    } do
      user = Factory.insert(:user)
      banned_until = Factory.insert(:ban, user: user).banned_until
      meta = %{socket: socket, user: user, banned_until: banned_until, result: :user_banned}

      expected_message =
        "Connection refused from user #{user.id} ip 200.120.10.67 with id #{id} due to user being banned until #{banned_until}"

      assert capture_log(log_func(event, meta)) =~ expected_message
    end
  end

  defp log_func(event, meta) do
    fn ->
      assert :ok == Console.handle_event(event, @measurements, meta, @config)
    end
  end
end
