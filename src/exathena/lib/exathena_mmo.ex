defmodule ExAthenaMmo do
  @moduledoc """
  The ExAthena MMO context.
  """

  @doc """
  Gets the file descriptor (FD) from given socket.

  ## Examples

      iex> get_socket_fd(#PID<0.18>)
      {:ok, 32}

      iex> get_socket_fd(#PID<0.17>)
      {:error, :eaddrinuse}

  """
  @spec get_socket_fd(port()) :: {:ok, non_neg_integer()} | {:error, any()}
  def get_socket_fd(socket) when is_port(socket), do: :inet.getfd(socket)

  @doc """
  Gets the ip address from given socket.

  ## Examples

      iex> get_socket_address(#PID<0.18>)
      {:ok, "12.154.32.241"}

      iex> get_socket_address(#PID<0.17>)
      {:error, :eaddrinuse}

  """
  @spec get_socket_address(port()) :: {:ok, String.t()} | {:error, any()}
  def get_socket_address(socket) when is_port(socket) do
    with {:ok, {ip, _port}} <- :inet.peername(socket) do
      ip_list = Tuple.to_list(ip)
      string_ip_list = Enum.map(ip_list, &to_string/1)

      {:ok, Enum.join(string_ip_list, ".")}
    end
  end
end
