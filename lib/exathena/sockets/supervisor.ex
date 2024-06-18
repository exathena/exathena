defmodule ExAthena.ServerSupervisor do
  @moduledoc """
  The ExAthena Server supervisor.

  It manages all server sockets to handle
  all received packets to create a new client
  socket GenServer.
  """
  use Supervisor

  @doc false
  @spec start_link(term()) :: GenServer.on_start()
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_opts) do
    children =
      for {id, server, options} <- get_servers() do
        Supervisor.child_spec({server, options}, id: id)
      end

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp get_servers() do
    {:ok, login_athena} = ExAthena.Config.login_athena()

    [
      {:login, ExAthena.LoginServerSocket,
       [
         name: LoginServer,
         ip: to_ip_address!(login_athena.bind_ip),
         port: login_athena.login_port
       ]}
    ]
  end

  defp to_ip_address!(ip) when is_binary(ip) do
    ip = String.to_charlist(ip)

    case :inet.parse_address(ip) do
      {:ok, ip} -> ip
      error -> raise ArgumentError, message: inspect(error)
    end
  end
end
