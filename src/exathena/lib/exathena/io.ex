defmodule ExAthena.IO do
  @moduledoc """
  The ExAthena IO operations with configuration/YAML files.

  It injects needed functions to starts all defined configurations, see
  `configuration/2`.

      defmodule MyApp.Settings do
        use ExAthena.IO

        alias MyApp.Settings.LoginAthena

        configure :conf do
          item :login_athena, schema: LoginAthena,
                              category: :login,
                              name: LoginAthenaConfig,
                              reload?: true
        end
      end

  Using the module above, our `MyApp.Config` can be started as supervisor and allow
  our system to start all configurations based on `configuration type`, which can be:

  - `:conf`: Designed to use our own implementation to parse the `conf` file recursively.
  - `:yaml`: Designed to use `yaml_elixir` library to parse the `yaml` file recursively.
  """
  alias ExAthena.IO.{
    InvalidOptionError,
    InvalidTypeError
  }

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Supervisor

      import ExAthena.IO
      require Logger

      alias ExAthena.IO.Item

      @typep configuration :: %{} | %{optional(atom()) => keyword()}

      @configuration_type :conf
      @configuration %{}
      @before_compile ExAthena.IO
    end
  end

  @doc """
  Configures the given supervisor with all items to be loaded,
  see `ExAthena.IO.Item`.

  ## Examples

      defmodule MyApp.Settings do
        use ExAthena.IO

        alias MyApp.Settings.LoginAthena

        configure :conf do
          item :login_athena, schema: LoginAthena,
                              category: :login,
                              name: LoginAthenaConfig,
                              reload?: true
        end
      end

      defmodule MyApp.Database do
        use ExAthena.IO

        alias MyApp.Database.AtCommand

        configure :conf do
          item :atcommands_db, schema: AtCommand,
                               category: :atcommands,
                               name: AtCommandDb,
                               reload?: true
        end
      end

  """
  defmacro configure(type, do: block) do
    quote location: :keep do
      ExAthena.IO.ensure_type!(unquote(type))

      @configuration_type unquote(type)
      unquote(block)
    end
  end

  @types [:conf, :yaml]

  @doc false
  def ensure_type!(type) when type in @types, do: :ok

  def ensure_type!(type) do
    raise InvalidTypeError, type: type
  end

  @doc """
  Inserts an item to be loaded by `ExAthena.IO.Item`.

  It requires some options, allowing the item to be loaded without
  configuration errors (parsing errors still happens if the file has
  invalid format).

  ## Options

    * `schema`   - The `ecto` schema to send to `changeset/2` function,
                   with the parsed data and validates if they have
                   valid values and types, according to the schema.

    * `category` - The category that given schema belongs to. It means
                   that, when the supervisor calls to reload their children
                   data, it should only reloads configurations with given category.

    * `name`     - The GenServer name to be started.

    * `reload?`  - Flag to define if given configuration item should be reloaded
                   when Supervisor asks to all childrens from given category
                   should reload, but only if this flag is set to `true`.
  """
  defmacro item(id, opts) do
    quote location: :keep do
      ExAthena.IO.ensure_opts!(unquote(opts))
      @configuration Map.put(@configuration, unquote(id), unquote(opts))
    end
  end

  @options [:schema, :category, :name, :reload?]

  @doc false
  def ensure_opts!(opts) do
    Enum.each(@options, fn option ->
      unless Keyword.has_key?(opts, option) do
        raise InvalidOptionError, option: option
      end
    end)
  end

  @doc false
  # credo:disable-for-next-line
  defmacro __before_compile__(_env) do
    quote do
      alias ExAthena.IO.Item

      @impl Supervisor
      def init(configuration) do
        children =
          Enum.map(configuration, fn {id, opts} ->
            options = Keyword.merge(opts, id: id, type: @configuration_type)
            Supervisor.child_spec({ExAthena.IO.Item, options}, id: id)
          end)

        Supervisor.init(children, strategy: :one_for_one)
      end

      @doc """
      Starts all configuration under the same supervisor.
      """
      def start_link(_) do
        Supervisor.start_link(__MODULE__, @configuration, name: __MODULE__)
      end

      @doc """
      Returns the loaded configuration

      ## Examples

          iex> configuration
          %{login_athena: [schema: LoginAthena, ...], ...}

      """
      @spec configuration() :: configuration()
      def configuration, do: @configuration

      @doc """
      Gets the item from configuration map and returns
      the opts and the ID from configuration.

      ## Examples

          iex> get(:login_athena)
          [id: :login_athena, schema: LoginAthena, ...]

      """
      @spec get(atom()) :: {:ok, keyword()} | {:error, :not_found}
      def get(id) do
        case Map.get(configuration(), id) do
          nil -> {:error, :not_found}
          item -> {:ok, Keyword.put(item, :id, id)}
        end
      end

      @doc """
      Reloads all item from given category that can be reladed.

      ## Examples

          iex> reload_items_from(:battle)
          # [info] Reloading configurations with "battle" category
          :ok

          iex> reload_items_from(:server)
          # [warn] Configuration items with category "server" can't be reloaded
          :ok

      """
      @spec reload_items_from(atom()) :: :ok
      def reload_items_from(category) when is_atom(category) do
        configuration()
        |> filter_by_category(category)
        |> filter_only_reloadable()
        |> maybe_do_reload(category)
      end

      defp filter_by_category(enumerable, category) when is_atom(category) do
        Enum.filter(enumerable, &(&1.category == category))
      end

      defp filter_only_reloadable(enumerable) do
        Enum.filter(enumerable, & &1.reload?)
      end

      defp maybe_do_reload([], category) do
        Logger.warn(~s/Configuration items with category "#{category}" can't be reloaded/,
          category: category
        )

        :ok
      end

      defp maybe_do_reload(items, category) do
        Logger.info(~s/Reloading configurations with "#{category}" category/,
          category: category
        )

        Enum.each(items, &Item.reload(&1))
      end
    end
  end
end
