defmodule ExAthena.IO.YamlParser do
  @moduledoc """
  The ExAthena Database YAML parser.
  """
  require Logger

  @doc """
  Parses the YAML database from given schema
  and returns it into a list of it's schema.

  ## Examples

      iex> parse_yaml(ExAthena.Database.Group)
      {:ok, [%Group{id: 0, name: "Player", ...}]}

      iex> parse_yaml(Foo)
      {:error, :invalid_format}

      iex> parse_yaml(Bar)
      {:error, :invalid_path}

      iex> parse_yaml(Baz)
      {:error, :invalid_schema}

  """
  @spec parse_yaml(String.t()) ::
          {:ok, list(map())}
          | {:ok, map()}
          | {:error, :invalid_format}
          | {:error, :invalid_path}
          | {:error, Ecto.Changeset.t()}
  def parse_yaml(yaml_path) when is_binary(yaml_path) do
    path = get_absolute_path(yaml_path)

    with {:error, error} <- do_read_file(path) do
      {reason, detail} =
        case error do
          exception = %YamlElixir.FileNotFoundError{} ->
            {:invalid_path, Exception.message(exception)}

          exception = %YamlElixir.ParsingError{} ->
            {:invalid_format, Exception.message(exception)}

          :invalid_format ->
            {:invalid_format, :invalid_format}
        end

      ExAthena.IO.Parser.show_error(path, reason, detail)
      {:error, reason}
    end
  end

  defp get_absolute_path(path) do
    base_path = Application.get_env(:exathena, :database_path, "")

    [base_path, "database", path]
    |> Path.join()
    |> Path.expand()
    |> Path.absname()
  end

  defp do_read_file(file_path) do
    file_path
    |> YamlElixir.read_from_file()
    |> maybe_import_other_files()
  end

  # TODO: Implement the "Imports" reading
  defp maybe_import_other_files({:ok, %{"Body" => body}}) do
    {:ok, body}
  end

  defp maybe_import_other_files({:ok, _}) do
    {:error, %YamlElixir.ParsingError{}}
  end

  defp maybe_import_other_files(other), do: other
end
