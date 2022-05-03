defmodule ExAthenaMmo.Server.Socket do
  @moduledoc false
  defstruct [:id, :name, :port, :listen_socket, :options]

  use GenServer

  require Logger

  alias ExAthenaMmo.Client
  alias __MODULE__

  @doc false
  def start_link(opts) do
    state = create_state(opts)
    GenServer.start_link(Socket, state, name: state.name)
  end

  defp create_state([:binary | opts]) do
    opts = Enum.into(opts, [])
    {id, opts} = Keyword.pop!(opts, :id)
    {name, opts} = Keyword.pop!(opts, :name)
    {port, opts} = Keyword.pop!(opts, :port)
    opts = [:binary | opts]

    struct!(Socket, id: id, name: name, port: port, options: opts)
  end

  ## Callbacks

  @impl true
  @doc false
  def init(state = %Socket{port: port, options: options}) do
    with {:ok, listen_socket} <- :gen_tcp.listen(port, options) do
      {:ok, %{state | listen_socket: listen_socket}, {:continue, :loop_acceptor}}
    end
  end

  @impl true
  @doc false
  def handle_continue(:loop_acceptor, state) do
    send(self(), :accept)
    {:noreply, state}
  end

  @impl true
  @doc false
  def handle_info(:accept, state = %Socket{id: :login, listen_socket: listen_socket}) do
    with {:ok, client_socket} <- :gen_tcp.accept(listen_socket) do
      listen(:login, client_socket)
    end

    {:noreply, state}
  end

  defp listen(server, client_socket, opts \\ []) do
    {:ok, pid} =
      DynamicSupervisor.start_child(Client, %{
        id: client_socket,
        start: {ExAthenaMmo.Client.Socket, :start_link, [server, client_socket, opts]},
        type: :worker
      })

    :gen_tcp.controlling_process(client_socket, pid)
  end
end
