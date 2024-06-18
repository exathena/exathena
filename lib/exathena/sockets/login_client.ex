defmodule ExAthena.LoginClientSocket do
  # TODO: Add module doc
  @moduledoc false
  use GenServer

  @doc false
  @spec start_link(port()) :: GenServer.on_start()
  def start_link(socket) do
    :inet.setopts(socket, active: true)
    GenServer.start_link(__MODULE__, socket)
  end

  ## Callbacks

  @impl true
  def init(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info({:tcp, socket, bytes}, socket) do
    {:noreply, handle_packet(socket, bytes)}
  end

  def handle_info({:tcp_closed, socket}, socket) do
    {:stop, :tcp_closed, socket}
  end

  def handle_info({:tcp_error, socket, reason}, socket) do
    {:stop, reason, socket}
  end

  def handle_info({:send, data}, socket) do
    :ok = :gen_tcp.send(socket, data)
    {:noreply, socket}
  end

  defp handle_packet(socket, _bytes) do
    # TODO: Implement when `exathena_packets` crate is available.
    #
    # When we receive the incoming data from the client, the server should
    # be able to deserialize the incoming packet into an Elixir struct using
    # the Rustler NIF.
    #
    # That said, we should send the PID on every packet because the packet processor
    # can send messages to this client whenever they want, so we should support the
    # `{:send, bytes}` message pattern. So, we should use `handle_packet(self(), packet)`.

    socket
  end
end
