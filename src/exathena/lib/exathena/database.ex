defmodule ExAthena.Database do
  @moduledoc """
  The ExAthena YAML database context.

  It exports an interface between all database
  contexts to manage YAML content easily.
  """
  use ExAthena.IO

  alias ExAthena.Database.{AtCommand, Group}

  configure :yaml do
    item :atcommand_db, schema: AtCommand, name: AtCommandDb, category: :atcommand, reload?: true
    item :player_group_db, schema: Group, name: PlayerGroupDb, category: :group, reload?: true
  end

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use ExAthena, :schema

      @doc """
      Parses the given attributes from source field to struct field, if needed.

      ## Examples

          iex> parse_attrs(%{"Command" => "foo", "Help" => "Foo"})
          %{"command" => "foo", "help" => "Foo"}

      """
      @spec parse_attrs(map()) :: map()
      def parse_attrs(attrs) when is_map(attrs) do
        fields = __schema__(:fields)

        mapper =
          Enum.reduce(fields, %{}, fn field, acc ->
            source = __schema__(:field_source, field)
            Map.put(acc, source, field)
          end)

        Enum.reduce(attrs, %{}, &parse_source_field(&1, &2, mapper))
      end

      defp parse_source_field({key, value}, acc, field_mapper) do
        atom_key = String.to_existing_atom(key)

        if field = field_mapper[atom_key] do
          Map.put(acc, field, value)
        else
          Map.put(acc, atom_key, value)
        end
      end
    end
  end

  @doc """
  Gets a list of all data from schema's GenServer.

  It's possible to send a keyword list as filter.

  ## Examples

      iex> all(PlayerGroupDb)
      [%AtCommand{}, ...]

      iex> all(PlayerGroupDb, commando: "Foo")
      [%AtCommand{command: "Foo"}, ...]

  """
  @spec all(module(), keyword()) :: list(Ecto.Schema.t())
  def all(db, filter \\ []), do: GenServer.call(db, {:all, filter})

  @doc """
  Gets one single record from schema's GenServer.

  ## Examples

      iex> get(PlayerGroupDb, 123)
      {:ok, %Group{id: 123}}

      iex> get(PlayerGroupDb, 456)
      {:error, :not_found}

  """
  @spec get(module(), non_neg_integer()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def get(db, id) do
    case GenServer.call(db, {:get, id}) do
      nil -> {:error, :not_found}
      item -> {:ok, item}
    end
  end

  @doc """
  Gets one single record from schema's GenServer by given filters.

  ## Examples

      iex> get_by(PlayerGroupDb, name: "Player")
      {:ok, %Group{name: "Player"}}

      iex> get_by(PlayerGroupDb, name: "Bar")
      {:error, :not_found}

  """
  @spec get_by(module(), keyword()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def get_by(db, filters) do
    case GenServer.call(db, {:get_by, filters}) do
      nil -> {:error, :not_found}
      item -> {:ok, item}
    end
  end
end
