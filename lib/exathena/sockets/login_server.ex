defmodule ExAthena.LoginServerSocket do
  # TODO: Add module doc
  @moduledoc false
  use GenServer

  @client ExAthena.LoginClientSocket
  @supervisor ExAthena.ServerDynamicSupervisor
  @options [active: false, reuseaddr: true, keepalive: true]

  @doc false
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    {name, opts} = Keyword.pop!(opts, :name)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  ## Callbacks

  @impl true
  def init(opts) do
    {port, opts} = Keyword.pop!(opts, :port)
    options = Keyword.merge(@options, opts)

    with {:ok, socket} <- :gen_tcp.listen(port, [:binary | options]) do
      {:ok, socket, {:continue, :accept}}
    end
  end

  @impl true
  def handle_continue(:accept, socket) do
    with {:ok, client_socket} <- :gen_tcp.accept(socket),
         {:ok, pid} <- start_client(client_socket) do
      :gen_tcp.controlling_process(client_socket, pid)
    end

    {:noreply, socket, {:continue, :accept}}
  end

  defp start_client(socket) do
    supervisor = {:via, PartitionSupervisor, {@supervisor, __MODULE__}}
    child_spec = %{id: socket, start: {@client, :start_link, [socket]}, type: :worker}

    DynamicSupervisor.start_child(supervisor, child_spec)
  end
end
