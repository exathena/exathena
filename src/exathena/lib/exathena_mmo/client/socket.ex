defmodule ExAthenaMmo.Client.Socket do
  @moduledoc false
  use GenServer

  require Logger

  alias ExAthenaMmo.Client.LoginSession

  @registry ExAthenaMmo.Registry

  @doc false
  def start_link(server, client_socket, opts \\ []) do
    :inet.setopts(client_socket, active: true)
    GenServer.start_link(__MODULE__, {server, client_socket, opts})
  end

  ## Callbacks

  @impl true
  @doc false
  def init({:login, client_socket, _opts}) do
    with {:ok, fd} <- ExAthenaMmo.get_socket_fd(client_socket) do
      login_session = struct!(LoginSession, fd: fd, socket: client_socket)
      {:ok, _} = Registry.register(@registry, {:login, fd}, login_session)

      {:ok, login_session}
    end
  end

  @impl true
  @doc false
  def handle_info({:tcp, _socket, data}, state) do
    Logger.info("Received message: #{inspect(data, limit: :infinity)}")
    # handle_packet(socket, router, data)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %LoginSession{fd: fd, socket: client_socket})
      when socket == client_socket do
    Registry.unregister(@registry, {:login, fd})
    {:noreply, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.error("Socket error: #{inspect(reason)}")
    {:noreply, state}
  end

  # defp handle_packet(socket, router, data) do
  #  with {:ok, packet_id} <- Parser.parse_packet_id(data),
  #       {:ok, router = %Router{}} <- Router.route(router, packet_id),
  #       {:ok, schema = %{id: ^packet_id}} <- Parser.parse(router, data) do
  #    call_controller(router, socket, schema)
  #  end
  # end

  # defp call_controller(%Router{controller: controller, action: action}, socket, schema)
  #     when is_port(socket) and is_struct(schema) do
  #  case apply(controller, action, [schema]) do
  #    {:ok, response} ->
  #      :gen_tcp.send(socket, response)

  #    error ->
  #      Logger.error("Received from controller: #{inspect(error)}")
  #  end
  # end
end
