defmodule ExAthenaMmo.Server do
  @moduledoc """
  The ExAthena MMO Server supervisor.

  It manages all server sockets to handle
  all received packets to create a new client
  socket GenServer.
  """
  use Supervisor

  alias ExAthena.Config
  alias ExAthena.Config.LoginAthena

  @default_options [:binary, active: false, reuseaddr: true, keepalive: true]

  def init(options) do
    children =
      Enum.map(options, fn {id, opts} ->
        options = @default_options ++ opts
        Supervisor.child_spec({ExAthenaMmo.Server.Socket, options}, id: id)
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link(_) do
    Supervisor.start_link(__MODULE__, get_server_config(), name: __MODULE__)
  end

  defp get_server_config do
    with {:ok, login_athena = %LoginAthena{}} <- Config.login_athena() do
      [
        login: [
          name: LoginServer,
          ip: to_ip_address!(login_athena.bind_ip),
          port: login_athena.login_port
        ]
      ]
    end
  end

  defp to_ip_address!(ip) when is_binary(ip) do
    case to_ip_address(ip) do
      {:ok, ip} -> ip
      error ->  raise ArgumentError, message: inspect(error)
    end
  end

  defp to_ip_address(ip) when is_binary(ip) do
    ip
    |> String.to_charlist()
    |> :inet.parse_address()
  end
end
