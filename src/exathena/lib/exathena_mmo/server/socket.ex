defmodule ExAthenaMmo.Server.Socket do
  @moduledoc false
  use GenServer

  defstruct [:name, :port, :listen_socket, :options]

  alias __MODULE__

  @impl true
  @doc false
  def init(state = %Socket{port: port, options: options}) do
    with {:ok, listen_socket} <- :gen_tcp.listen(port, options) do
      {:ok, %{state | listen_socket: listen_socket}, {:continue, :loop_acceptor}}
    end
  end

  @doc false
  def start_link(opts) do
    state = create_state(opts)
    GenServer.start_link(Socket, state, name: state.name)
  end

  defp create_state([:binary | opts]) do
    opts = Enum.into(opts, [])
    {name, opts} = Keyword.pop!(opts, :name)
    {port, opts} = Keyword.pop!(opts, :port)
    opts = [:binary | opts]

    struct!(Socket, [name: name, port: port, options: opts])
  end

  # Callbacks

  @impl true
  @doc false
  def handle_continue(:loop_acceptor, state) do
    send(self(), :accept)
    {:noreply, state}
  end

  @impl true
  @doc false
  def handle_info(:accept, state = %Socket{listen_socket: _listen_socket}) do
    {:noreply, state}
  end
end
