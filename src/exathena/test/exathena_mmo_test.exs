defmodule ExAthenaMmoTest do
  use ExAthena.SocketCase

  describe "get_socket_fd/1" do
    test "gets the file descriptor from socket", %{socket: socket} do
      assert {:ok, fd} = ExAthenaMmo.get_socket_fd(socket)
      assert is_integer(fd)
    end

    test "returns error", %{socket: socket} do
      assert :ok == :gen_tcp.close(socket)
      assert {:error, :einval} = ExAthenaMmo.get_socket_fd(socket)
    end
  end

  describe "get_socket_address/1" do
    test "gets the ip from socket", %{socket: socket} do
      assert {:ok, "127.0.0.1"} = ExAthenaMmo.get_socket_address(socket)
    end

    test "returns error", %{socket: socket} do
      assert :ok == :gen_tcp.close(socket)
      assert {:error, :einval} = ExAthenaMmo.get_socket_address(socket)
    end
  end
end
