defmodule ExAthena.IO.YamlParser do
  @moduledoc """
  The ExAthena Database YAML parser.
  """
  require Logger

  alias Ecto.Changeset
  alias YamlElixir.{FileNotFoundError, ParsingError}

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
          | {:error, Changeset.t()}
  def parse_yaml(yaml_path) when is_binary(yaml_path) do
    yaml_path
    |> get_file_path()
    |> do_read_file()
    |> handle_error()
  end

  defp get_file_path(yaml_path) do
    base_path = Application.get_env(:exathena, :database_path, "")

    [base_path, "database", yaml_path]
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
    {:error, :invalid_format}
  end

  defp maybe_import_other_files(other), do: other

  defp handle_error({:ok, items = [_ | _]}) do
    {:ok, items}
  end

  defp handle_error({:error, error = %ParsingError{}}) do
    Logger.error("Failed to parse YAML file",
      error: true,
      error_detail: Exception.message(error)
    )

    {:error, :invalid_format}
  end

  defp handle_error(error = {:error, :invalid_format}) do
    Logger.error("Failed to parse YAML file",
      error: true,
      error_detail: inspect(error)
    )

    error
  end

  defp handle_error({:error, error = %FileNotFoundError{}}) do
    Logger.error("The given YAML file doesn't not exist",
      error: true,
      error_detail: Exception.message(error)
    )

    {:error, :invalid_path}
  end
end
