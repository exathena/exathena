defmodule ExAthena.Database do
  @moduledoc """
  The ExAthena YAML database context.

  It exports an interface between all database
  contexts to manage YAML content easily.
  """
  use ExAthena.IO

  configure :yaml do
    item :atcommand_db,
      schema: ExAthena.Database.AtCommand,
      name: AtCommandDb,
      category: :atcommand,
      reload?: true

    item :player_group_db,
      schema: ExAthena.Database.Group,
      name: PlayerGroupDb,
      category: :group,
      reload?: true
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

      iex> all(PlayerGroupDb, command: "Foo")
      [%AtCommand{command: "Foo"}, ...]

  """
  @spec all(module(), keyword()) :: list(Ecto.Schema.t())
  def all(db, filters \\ []) do
    db
    |> check_if_is_alive()
    |> do_list_all(filters)
    |> case do
      {:error, _} -> []
      result -> result
    end
  end

  @doc """
  Gets one single record from schema's GenServer.

  ## Examples

      iex> get(PlayerGroupDb, 123)
      {:ok, %Group{id: 123}}

      iex> get(PlayerGroupDb, 456)
      {:error, :not_found}

  """
  @spec get(module(), non_neg_integer()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found | :server_down}
  def get(db, id) do
    db
    |> check_if_is_alive()
    |> do_get(id)
    |> case do
      error = {:error, _} -> error
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
  @spec get_by(module(), keyword()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found | :server_down}
  def get_by(db, filters) do
    db
    |> check_if_is_alive()
    |> do_get_by(filters)
    |> case do
      error = {:error, _} -> error
      nil -> {:error, :not_found}
      item -> {:ok, item}
    end
  end

  # Private

  defp check_if_is_alive(name) do
    case GenServer.whereis(name) do
      nil -> {:error, :server_down}
      _ -> name
    end
  end

  defp do_get(error = {:error, _}, _), do: error
  defp do_get(db, id), do: Item.get(db, id)

  defp do_get_by(error = {:error, _}, _), do: error
  defp do_get_by(db, filters), do: Item.get_by(db, filters)

  defp do_list_all(error = {:error, _}, _), do: error
  defp do_list_all(db, filters), do: Item.list_all(db, filters)
end
