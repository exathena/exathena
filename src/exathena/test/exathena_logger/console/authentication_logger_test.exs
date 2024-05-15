defmodule ExAthenaLogger.Console.AuthenticationLoggerTest do
  use ExAthenaLogger.DataCase, async: true

  @duration_ms 12_345
  @measurements %{duration_ms: @duration_ms}

  alias ExAthenaLogger.Console.AuthenticationLogger

  setup do
    {:ok, socket: join_public_channel(ExAthenaWeb.LoginChannel, "login")}
  end

  describe "get_log_message/1" do
    test "returns log message for request authentication", %{socket: socket} do
      meta = %{socket: socket, type: :request}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Received request authentication from ip 200.120.10.67"
    end

    test "returns log message for accepted connection", %{socket: socket} do
      user = Factory.insert(:user)
      meta = %{socket: socket, user: user, result: :accepted}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Connection accepted from ip 200.120.10.67 associated to user #{user.id}"
    end

    test "returns log message for invalid credentials", %{socket: socket} do
      meta = %{socket: socket, result: :invalid_credentials}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Connection refused from ip 200.120.10.67 due to invalid credentials"
    end

    test "returns log message for user already banned", %{socket: socket = %{id: id}} do
      user = Factory.insert(:user)
      ban = Factory.insert(:ban, user: user)
      meta = %{socket: socket, user: user, banned_until: ban.banned_until, result: :user_banned}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Connection refused from user #{user.id} ip 200.120.10.67 with id #{id} due to user being banned until #{ban.banned_until}"
    end

    test "returns log message for not found username", %{socket: socket} do
      meta = %{socket: socket, result: :not_found}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Connection refused from ip 200.120.10.67 due to not found the given username"
    end

    test "returns log message for user with access expired", %{socket: socket} do
      meta = %{socket: socket, result: :access_expired}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Connection refused from ip 200.120.10.67 due to access expired"
    end
  end

  describe "build_metadata/2" do
    test "returns log metadata for request authentication", %{
      socket: socket = %{join_ref: join_ref}
    } do
      meta = %{socket: socket, type: :request}

      assert %{duration_ms: @duration_ms, join_ref: ^join_ref} =
               AuthenticationLogger.build_metadata(@measurements, meta)
    end

    test "returns log metadata for accepted connection", %{socket: socket = %{join_ref: join_ref}} do
      user = Factory.insert(:user)
      meta = %{socket: socket, user: user, result: :accepted}
      user_id = user.id

      assert %{duration_ms: @duration_ms, join_ref: ^join_ref, user_id: ^user_id} =
               AuthenticationLogger.build_metadata(@measurements, meta)
    end

    test "returns log metadata for invalid credentials", %{socket: socket = %{join_ref: join_ref}} do
      meta = %{socket: socket, result: :invalid_credentials}

      assert %{duration_ms: @duration_ms, join_ref: ^join_ref} =
               AuthenticationLogger.build_metadata(@measurements, meta)
    end

    test "returns log metadata for user already banned", %{socket: socket = %{join_ref: join_ref}} do
      user = Factory.insert(:user)
      banned_until = Factory.insert(:ban, user: user).banned_until
      user_id = user.id

      meta = %{socket: socket, user: user, banned_until: banned_until, result: :user_banned}

      assert %{
               duration_ms: @duration_ms,
               banned_until: ^banned_until,
               join_ref: ^join_ref,
               user_id: ^user_id
             } = AuthenticationLogger.build_metadata(@measurements, meta)
    end
  end

  @expected_log_level [
    {:type, :request, :debug},
    {:result, :accepted, :info},
    {:result, :invalid_credentials, :warning},
    {:result, :user_banned, :error}
  ]

  test "get_log_type/1 returns log type for request authentication" do
    for {key, value, level} <- @expected_log_level do
      assert AuthenticationLogger.get_log_type(%{key => value}) == level
    end
  end
end
