defmodule ExAthena.IO.Item do
  @moduledoc """
  The GenServer abstraction to start every configuration item
  from his supervisor.

  It loads either `.conf` and `.yml/yaml` files, attaching their
  data to the process state.
  """
  use GenServer

  @doc """
  Starts the configurtion item with given options
  """
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts) do
    {name, opts} = Keyword.pop!(opts, :name)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Triggers the reload action asynchronous

  ## Examples

      iex> Item.reload(LoginAthena)
      :ok

  """
  @spec reload(GenServer.server()) :: :ok | {:error, :invalid_path | :invalid_format}
  def reload(server) do
    GenServer.call(server, :reload)
  end

  @doc """
  Gets the actual data from state.

  ## Examples

      iex> Item.get_data(LoginAthena)
      %LoginAthena{}

      iex> Item.get_data(LoginAthena)
      nil

  """
  @spec get_data(GenServer.server()) :: nil | Ecto.Schema.t()
  def get_data(server) do
    GenServer.call(server, :get_data)
  end

  @doc """
  Gets a list of data based on given filter.

  ## Examples

      iex> Item.list_all(AtCommandDb)
      [%AtCommand{}, ...]

      iex> Item.list_all(AtCommandDb, commando: "Foo")
      [%AtCommand{command: "Foo"}, ...]

  """
  @spec list_all(GenServer.server(), keyword()) :: list(Ecto.Schema.t())
  def list_all(server, filters \\ []) do
    GenServer.call(server, {:all, filters})
  end

  @doc """
  Gets one data based on given ID.

  ## Examples

      iex> Item.get(AtCommandDb, 1)
      [%AtCommand{id: 1}, ...]

      iex> Item.get(AtCommandDb, 2)
      nil

  """
  @spec get(GenServer.server(), non_neg_integer()) :: nil | Ecto.Schema.t()
  def get(server, id) do
    GenServer.call(server, {:get, id})
  end

  @doc """
  Gets one data based on given filter.

  ## Examples

      iex> Item.get_by(PlayerGroupDb, name: "Player")
      %Group{name: "Player"}

      iex> Item.get_by(PlayerGroupDb, name: "Bar")
      nil

  """
  @spec get_by(GenServer.server(), keyword()) :: nil | Ecto.Schema.t()
  def get_by(server, filters) do
    GenServer.call(server, {:get_by, filters})
  end

  ## GenServer Callbacks

  @impl true
  def init(opts) do
    {:ok, %{data: nil, options: opts}, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    case load_item_data(state) do
      {:ok, state} -> {:noreply, state}
      {:error, reason} -> {:stop, "Failed to load the data due to #{reason}", state}
    end
  end

  @impl true
  def handle_call(:reload, _from, state) do
    case load_item_data(state) do
      {:ok, state} -> {:reply, :ok, state}
      {:error, _} = error -> {:reply, error, state}
    end
  end

  def handle_call(:get_data, _from, state) do
    {:reply, state.data, state}
  end

  def handle_call({:all, filters}, _from, state) do
    {:reply, do_list_all(state, filters), state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, do_get(state, id), state}
  end

  def handle_call({:get_by, filters}, _from, state) do
    {:reply, do_get_by(state, filters), state}
  end

  ## Private functions

  defp do_list_all(%{data: items = [_ | _]}, filters) do
    do_build_filter(items, filters, &Enum.filter/2)
  end

  defp do_list_all(_, _), do: []

  defp do_get(%{data: items = [_ | _]}, id) do
    Enum.find(items, fn item ->
      [{field, _}] = Ecto.primary_key(item)
      Map.get(item, field) == id
    end)
  end

  defp do_get(_, _), do: nil

  defp do_get_by(%{data: items = [_ | _]}, filters) do
    do_build_filter(items, filters, &Enum.find/2)
  end

  defp do_get_by(_, _), do: nil

  defp do_build_filter(items = [%module{} | _], filters, func) do
    fields = module.__schema__(:fields)

    Enum.reduce(filters, items, fn {field, value}, acc ->
      if field in fields do
        func.(acc, &do_filter_item(&1, field, value))
      else
        acc
      end
    end)
  end

  defp do_filter_item(item, field, value) do
    Map.get(item, field) == value
  end

  defp load_item_data(state = %{options: options}) do
    type = Keyword.fetch!(options, :type)
    schema = Keyword.fetch!(options, :schema)

    with {:ok, data} <- ExAthena.IO.Parser.load(type, schema) do
      {:ok, %{state | data: data}}
    end
  end
end
