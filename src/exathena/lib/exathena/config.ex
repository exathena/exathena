defmodule ExAthena.Config do
  @moduledoc """
  The ExAthena Config context.

  It handles all .conf files located at `settings`
  path in root umbrella project.
  """
  use GenServer

  require Logger

  alias Ecto.Changeset
  alias ExAthena.Config.Entry, as: Config
  alias ExAthena.Config.{LoginAthena, Parser}
  alias ExAthena.Config.Registry, as: ConfigRegistry

  @configs [
    %Config{
      id: :login_athena,
      name: LoginAthenaConfig,
      type: :server,
      path: "./settings/login_athena.conf",
      reload?: false,
      schema: LoginAthena
    }
  ]

  ## GenServer behaviour

  @impl true
  def init(state = %Config{}) do
    Logger.info("Reading file #{state.path}",
      config_id: state.id,
      config: inspect(state)
    )

    with {:ok, attrs} <- Parser.parse_config(state.path),
         {:ok, config} <- cast_config(state.schema, attrs) do
      state = %{state | data: config}
      persist_config(state)

      {:ok, %{state | data: config}}
    else
      {:error, reason} ->
        Logger.error("Failed to read #{Path.basename(state.path)}",
          config_id: state.id,
          config: inspect(state),
          error: true,
          error_detail: inspect(reason)
        )

        {:stop, reason}
    end
  end

  defp cast_config(module, attrs) when is_atom(module) do
    module
    |> struct!()
    |> module.changeset(attrs)
    |> Changeset.apply_action(:build)
  end

  defp persist_config(state = %Config{}) do
    case Registry.lookup(ConfigRegistry, state.id) do
      [{_, _}] -> Registry.update_value(ConfigRegistry, state.id, fn _ -> state end)
      [] -> Registry.register(ConfigRegistry, state.id, state)
    end
  end

  @doc """
  Starts the config GenServer from given config entry

  ## Examples

      iex> start_link(%Config{name: :foo})
      {:ok, #PID<0.18>}

      iex> start_link(%Config{name: :foo})
      {:error, {:already_started, #PID<0.18}

  """
  @spec start_link(Config.t()) :: GenServer.on_start()
  def start_link(config = %Config{name: name}) do
    GenServer.start_link(__MODULE__, config, name: name)
  end

  ## Callbacks

  @impl true
  def handle_call(:reload, _from, state = %Config{reload?: true}) do
    with {:ok, config} <- init(state) do
      {:reply, :ok, config}
    end
  end

  def handle_call(:reload, _from, state = %Config{reload?: false}) do
    {:reply, :ok, state}
  end

  ## Public functions

  @doc """
  Returns the raw configs list
  """
  @spec __configs__() :: list(Config.t())
  def __configs__ do
    Enum.map(@configs, fn config = %Config{id: config_id} ->
      case Registry.lookup(ConfigRegistry, config_id) do
        [{_, config}] ->
          config

        [] ->
          Logger.warn("""
          The config #{config_id} didn't started yet.
          Fallbacking to config from compilation.
          """)

          config
      end
    end)
  end

  @doc """
  Starts all config GenServers.
  """
  @spec start_configs() :: list({module(), Config.t()})
  def start_configs do
    Enum.map(@configs, fn config = %Config{} ->
      {__MODULE__, config}
    end)
  end

  @doc """
  Gets the list of configs from current ExAthena application.

  ## Examples

      iex> get_config_data(:login_athena)
      {:ok, %LoginAthena{login_port: 6900, ...}}

      iex> get_config_data(:foo)
      {:error, :not_found}

  """
  @spec get_config_data(atom()) :: {:ok, struct()} | {:error, :not_found}
  def get_config_data(id) do
    case Registry.lookup(ConfigRegistry, id) do
      [] -> {:error, :not_found}
      [{_, %Config{data: data}}] -> {:ok, data}
    end
  end

  @doc """
  Reloads all configs from given type that can be reladed.

  ## Examples

      iex> reload_config(:battle)
      # [info] Reloading battle config
      :ok

      iex> reload_config(:server)
      # [warn] Configs with type server can't be reloaded
      :ok

  """
  @spec reload_config(atom()) :: :ok
  def reload_config(config_type) when is_atom(config_type) do
    __configs__()
    |> filter_configs_by_type(config_type)
    |> filter_reloadable_configs()
    |> maybe_do_reload_config(config_type)
  end

  defp filter_configs_by_type(enumerable, config_type) when is_atom(config_type) do
    Enum.filter(enumerable, &(&1.type == config_type))
  end

  defp filter_reloadable_configs(enumerable) do
    Enum.filter(enumerable, & &1.reload?)
  end

  defp maybe_do_reload_config([], config_type) do
    Logger.warn("Configs with type #{config_type} can't be reloaded", config_type: config_type)
    :ok
  end

  defp maybe_do_reload_config(configs, config_type) do
    Logger.info("Reloading #{config_type} config", config_type: config_type)
    Enum.each(configs, &reload(&1.name))
  end

  defp reload(config_name) do
    GenServer.call(config_name, :reload)
  end
end
