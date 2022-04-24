defmodule ExAthena.IO.Parser do
  @moduledoc """
  The ExAthena file parser.

  It parses `.conf` and `yaml/yml` files recursively.
  """

  alias Ecto.Changeset
  alias ExAthena.IO.{ConfParser, YamlParser}

  @doc """
  Loads the data from given module based on given configuration type.

  It raises an exception if:

    * File can't be read;
    * The content from file has invalid format to be parsed;
    * THe content from file has invalid type for given schema.

  ## Examples

      iex> Parser.load(:conf, LoginAthena)
      {:ok, %LoginAthena{}}

      iex> Parser.load(:conf, InvalidFormat)
      {:error, :invalid_format}

      iex> Parser.load(:conf, InvalidPath)
      {:error, :invalid_path}

      iex> Parser.load(:conf, InvalidData)
      {:error, %Ecto.Changeset{}}

  """
  @spec load(atom(), module()) ::
          {:ok, Ecto.Schema.t()} | {:error, :invalid_path | :invalid_format | Ecto.Changeset.t()}
  def load(configuration_type, module)

  def load(:conf, module) do
    config_path = module.__schema__(:source)

    case ConfParser.parse_config(config_path) do
      {:ok, attrs} -> build_schema(attrs, module)
      error = {:error, _} -> error
    end
  end

  def load(:yaml, module) do
    yaml_path = module.__schema__(:source)

    case YamlParser.parse_yaml(yaml_path) do
      {:ok, list_of_attrs = [_ | _]} -> build_schemas(list_of_attrs, module)
      error = {:error, _} -> error
    end
  end

  defp build_schemas(list_of_attrs = [_ | _], module) do
    Enum.reduce_while(list_of_attrs, {:ok, []}, fn attrs, {:ok, acc} ->
      case build_schema(attrs, module) do
        {:ok, struct} -> {:cont, {:ok, acc ++ [struct]}}
        error = {:error, _changeset} -> {:halt, error}
      end
    end)
  end

  defp build_schema(attrs, module) do
    module
    |> struct()
    |> module.changeset(attrs)
    |> Changeset.apply_action(:parsed)
  end
end
