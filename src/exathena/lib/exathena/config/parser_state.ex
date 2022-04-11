defmodule ExAthena.Config.ParserState do
  @moduledoc false
  alias __MODULE__, as: State

  @true_boolean_words ~w(yes true on)
  @false_boolean_words ~w(no false off)
  @reserved_boolean_words @true_boolean_words ++ @false_boolean_words

  @typep key :: String.t()
  @typep value :: String.t() | boolean() | integer()
  @typep result :: {:ok, map()} | {:error, any()}

  # Struct definition
  @struct [
    # The file name
    file_name: 0,
    # What line of the "file" are we parsing
    line_number: 1,
    # What the next file to be importted
    imports: [],
    # The result as it is being built.
    result: {:ok, %{}}
  ]

  @typedoc """
  The Parser State type
  """
  @type t :: %State{
          file_name: String.t(),
          line_number: pos_integer(),
          imports: list(String.t()),
          result: result()
        }

  defstruct @struct

  @doc """
  Defines a config to current `State` with given key and value.

  ## Examples

      iex> define_config(%State{result: {:ok, %{}}}, "foo", "bar")
      %State{result: {:ok, %{"foo" => "bar"}}}

      iex> define_config(%State{imports: []}, "import", "settings/bar.conf")
      %State{imports: ["settings/bar.conf"]}

      iex> define_config(%State{result: {:ok, %{}}}, "foo", nil)
      %State{result: {:ok, %{}}}

      iex> define_config(%State{result: {:error, :reason}}, "foo", "bar")
      %State{result: {:error, :reason}}

  """
  @spec define_config(t(), key(), value()) :: t()
  def define_config(state, key, value)

  def define_config(state = %State{result: {:error, _}}, _key, _value), do: state

  def define_config(state = %State{result: {:ok, _}}, _key, value)
      when is_nil(value) or value == "",
      do: state

  def define_config(state = %State{imports: imports}, "import", path) do
    %{state | imports: [path | imports]}
  end

  def define_config(state = %State{result: {:ok, config}}, key, value) when is_binary(key) do
    new_config = Map.put_new(config, key, convert_value(value))

    %{state | result: {:ok, new_config}}
  end

  # It tries to convert data to their type.
  # Default: string
  #
  # Note: We don't really know their type at this time,
  #       so we'll define based on their value and then
  #       we will validate their type later on.
  defp convert_value(value) do
    cond do
      is_boolean?(value) ->
        convert_boolean(value)

      is_int?(value) ->
        convert_integer(value)

      is_float_or_decimal?(value) ->
        convert_decimal(value)

      is_atom?(value) ->
        String.to_existing_atom(value)

      is_list?(value) ->
        convert_list(value)

      true ->
        value
    end
  end

  defp is_atom?(value) do
    _ = String.to_existing_atom(value)
    true
  rescue
    _ -> false
  end

  defp is_boolean?(value) when value in @reserved_boolean_words, do: true
  defp is_boolean?(_), do: false

  defp is_float_or_decimal?(value) do
    case Regex.run(~r/^\d*\.?\d+$/, value) do
      [^value] -> true
      _ -> false
    end
  end

  defp is_int?(value) do
    case Regex.run(~r/^-?[0-9]*$/, value) do
      [^value] -> true
      nil -> false
    end
  end

  defp is_list?(value) do
    case Regex.run(~r/[,]/, value) do
      [_ | _] -> true
      nil -> false
    end
  end

  defp convert_boolean(value) when value in @true_boolean_words, do: true
  defp convert_boolean(value) when value in @false_boolean_words, do: true
  defp convert_decimal(value), do: Decimal.new(value)
  defp convert_integer(value), do: String.to_integer(value)

  defp convert_list(value) do
    value
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end
end
