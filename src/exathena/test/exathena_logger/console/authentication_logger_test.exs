defmodule ExAthenaLogger.Console.AuthenticationLoggerTest do
  use ExAthenaLogger.DataCase

  @duration_ms 12_345
  @measurements %{duration_ms: @duration_ms}

  alias ExAthenaLogger.Console.AuthenticationLogger

  describe "get_log_message/1" do
    test "returns log message for request authentication", %{socket: socket} do
      meta = %{socket: socket, type: :request}

      assert "Received request authentication from ip 127.0.0.1" ==
               AuthenticationLogger.get_log_message(meta)
    end

    test "returns log message for accepted connection", %{socket: socket} do
      user = Factory.insert(:user)
      meta = %{socket: socket, user: user, result: :accepted}

      assert "Connection accepted from ip 127.0.0.1 associated to user #{user.id}" ==
               AuthenticationLogger.get_log_message(meta)
    end

    test "returns log message for invalid credentials", %{socket: socket} do
      meta = %{socket: socket, result: :invalid_credentials}

      assert "Connection refused from ip 127.0.0.1 due to invalid credentials" ==
               AuthenticationLogger.get_log_message(meta)
    end

    test "returns log message for user already banned", %{socket: socket} do
      user = Factory.insert(:user)
      ban = Factory.insert(:ban, user: user)
      meta = %{socket: socket, user: user, banned_until: ban.banned_until, result: :user_banned}

      assert {:ok, ip} = ExAthenaMmo.get_socket_address(socket)
      assert {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

      assert "Connection refused from user #{user.id} ip #{ip} with fd #{socket_fd} due to user being banned until #{ban.banned_until}" ==
               AuthenticationLogger.get_log_message(meta)
    end
  end

  describe "build_metadata/2" do
    test "returns log metadata for request authentication", %{socket: socket} do
      meta = %{socket: socket, type: :request}

      assert {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

      assert %{duration_ms: @duration_ms, socket_fd: ^socket_fd} =
               AuthenticationLogger.build_metadata(@measurements, meta)
    end

    test "returns log metadata for accepted connection", %{socket: socket} do
      user = Factory.insert(:user)
      meta = %{socket: socket, user: user, result: :accepted}
      user_id = user.id

      assert {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

      assert %{duration_ms: @duration_ms, socket_fd: ^socket_fd, user_id: ^user_id} =
               AuthenticationLogger.build_metadata(@measurements, meta)
    end

    test "returns log metadata for invalid credentials", %{socket: socket} do
      meta = %{socket: socket, result: :invalid_credentials}

      assert {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

      assert %{duration_ms: @duration_ms, socket_fd: ^socket_fd} =
               AuthenticationLogger.build_metadata(@measurements, meta)
    end

    test "returns log metadata for user already banned", %{socket: socket} do
      user = Factory.insert(:user)
      banned_until = Factory.insert(:ban, user: user).banned_until
      user_id = user.id

      meta = %{socket: socket, user: user, banned_until: banned_until, result: :user_banned}

      assert {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

      assert %{
               duration_ms: @duration_ms,
               banned_until: ^banned_until,
               socket_fd: ^socket_fd,
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
