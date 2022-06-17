defmodule ExAthenaLogger.Console.AuthenticationLoggerTest do
  use ExAthenaLogger.DataCase

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

    test "returns log message for user already banned", %{
      socket: socket = %{id: id, join_ref: join_ref}
    } do
      user = Factory.insert(:user)
      ban = Factory.insert(:ban, user: user)
      meta = %{socket: socket, user: user, banned_until: ban.banned_until, result: :user_banned}

      assert AuthenticationLogger.get_log_message(meta) ==
               "Connection refused from user #{user.id} ip 200.120.10.67 with id #{id} due to user being banned until #{ban.banned_until}"
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

  describe "get_log_type/1" do
    test "returns log type for request authentication" do
      assert :debug == AuthenticationLogger.get_log_type(%{type: :request})
    end

    test "returns log type for accepted connection" do
      assert :info == AuthenticationLogger.get_log_type(%{result: :accepted})
    end

    test "returns log type for invalid credentials" do
      assert :warn == AuthenticationLogger.get_log_type(%{result: :invalid_credentials})
    end

    test "returns log type for user already banned" do
      assert :error == AuthenticationLogger.get_log_type(%{result: :user_banned})
    end
  end
end
