defmodule ExAthenaLogger.Console.AuthenticationLogger do
  @moduledoc """
  The ExAthena Logger handler for authentication events.
  """
  @behaviour ExAthenaLogger.Console

  @impl true
  def get_log_message(%{socket: socket, type: :request}) do
    {:ok, ip} = ExAthenaMmo.get_socket_address(socket)

    "Received request authentication from ip #{ip}"
  end

  def get_log_message(%{socket: socket, result: :invalid_credentials}) do
    {:ok, ip} = ExAthenaMmo.get_socket_address(socket)

    "Connection refused from ip #{ip} due to invalid credentials"
  end

  def get_log_message(%{
        socket: socket,
        user: user,
        banned_until: banned_until,
        result: :user_banned
      }) do
    {:ok, ip} = ExAthenaMmo.get_socket_address(socket)
    {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

    "Connection refused from user #{user.id} ip #{ip} with fd #{socket_fd} due to user being banned until #{banned_until}"
  end

  def get_log_message(%{socket: socket, user: user, result: :accepted}) do
    {:ok, ip} = ExAthenaMmo.get_socket_address(socket)

    "Connection accepted from ip #{ip} associated to user #{user.id}"
  end

  @impl true
  def build_metadata(measurements, %{user: user, socket: socket, banned_until: banned_until}) do
    {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

    Map.merge(measurements, %{
      user_id: user.id,
      banned_until: banned_until,
      socket_fd: socket_fd
    })
  end

  def build_metadata(measurements, %{user: user, socket: socket}) do
    {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

    Map.merge(measurements, %{
      user_id: user.id,
      socket_fd: socket_fd
    })
  end

  def build_metadata(measurements, %{socket: socket}) do
    {:ok, socket_fd} = ExAthenaMmo.get_socket_fd(socket)

    Map.merge(measurements, %{socket_fd: socket_fd})
  end

  @impl true
  def get_log_type(%{type: :request}), do: :debug
  def get_log_type(%{result: :accepted}), do: :info
  def get_log_type(%{result: :user_banned}), do: :error
  def get_log_type(%{result: _}), do: :warn
end
