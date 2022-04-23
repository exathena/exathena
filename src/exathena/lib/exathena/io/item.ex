defmodule ExAthena.IO.Item do
  @moduledoc """
  The GenServer abstraction to start every configuration item
  from his supervisor.

  It loads either `.conf` and `.yml/yaml` files, attaching their
  data to the process state.
  """
  use GenServer

  alias __MODULE__
  alias ExAthena.IO.Parser

  @typedoc """
  The Configuration Item type
  """
  @type t :: %__MODULE__{
          data: nil | Ecto.Schema.t(),
          options: keyword()
        }

  defstruct [
    # The file data
    data: nil,
    # The configuration options
    options: []
  ]

  ## GenServer Behaviour

  @impl true
  def init(state = %Item{}) do
    {:ok, state, {:continue, :load}}
  end

  ## GenServer Callbacks

  @impl true
  def handle_continue(:load, state = %Item{}) do
    {:noreply, load_item_data!(state)}
  end

  @impl true
  def handle_call(:reload, _from, state = %Item{}) do
    {:reply, :ok, load_item_data!(state)}
  end

  def handle_call({:all, filters}, _from, state = %Item{}) do
    {:reply, list_all(state, filters), state}
  end

  def handle_call({:get, id}, _from, state = %Item{}) do
    {:reply, get(state, id), state}
  end

  def handle_call({:get_by, filters}, _from, state = %Item{}) do
    {:reply, get_by(state, filters), state}
  end

  ## Public interface

  @doc """
  Starts the configurtion item with given options
  """
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, %Item{options: opts}, name: opts[:name])
  end

  @doc """
  Triggers the reload action asynchronous

  ## Examples

      iex> Item.reload(LoginAthena)
      :ok

  """
  @spec reload(module()) :: :ok
  def reload(name) do
    GenServer.call(name, :reload)
  end

  ## Private functions

  defp list_all(%Item{data: items = [_ | _]}, filters) do
    do_build_filter(items, filters, &Enum.filter/2)
  end

  defp list_all(%Item{}, _), do: []

  defp get(%Item{data: items = [_ | _]}, id) do
    Enum.find(items, fn item ->
      [{field, _}] = Ecto.primary_key(item)
      Map.get(item, field) == id
    end)
  end

  defp get(%Item{}, _), do: nil

  defp get_by(%Item{data: items = [_ | _]}, filters) do
    do_build_filter(items, filters, &Enum.find/2)
  end

  defp get_by(%Item{}, _), do: nil

  defp do_build_filter(items = [%module{} | _], filters, func) do
    fields = module.__schema__(:fields)

    Enum.reduce(filters, items, fn {field, value}, acc ->
      if field in fields do
        func.(acc, fn item -> Map.get(item, field) == value end)
      else
        acc
      end
    end)
  end

  defp load_item_data!(state = %Item{options: options}) do
    type = Keyword.fetch!(options, :type)
    schema = Keyword.fetch!(options, :schema)
    {:ok, data} = Parser.load(type, schema)

    %{state | data: data}
  end
end
