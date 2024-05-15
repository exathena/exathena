defmodule ExAthena.IO.ConfParser do
  @moduledoc """
  The ExAthena `.conf` parser.
  """
  require Logger

  alias ExAthena.IO.ConfParser.State

  @double_slash_comment_regex ~r{^\/\/.*}
  @colon_definition_regex ~r{([^:]+):(.*)}

  @doc """
  Parses the config from given path and
  returns it into a map.

  ## Examples

      iex> parse_config("login_athena.conf")
      {:ok, %{login_port: 6900, stdout_with_ansisequence: false, ...}}

      iex> parse_config("empty.conf")
      {:ok, %{}}

      iex> parse_config("invalid_format.conf")
      {:error, :invalid_format}

      iex> parse_config("foo.conf")
      {:error, :invalid_path}

  """
  @spec parse_config(String.t()) :: {:ok, map()} | {:error, :invalid_format | :invalid_path}
  def parse_config(config_path) when is_binary(config_path) do
    base_path = Application.get_env(:exathena, :settings_path, "")

    path =
      [base_path, "settings", config_path]
      |> Path.join()
      |> Path.expand()
      |> Path.absname()

    with :ok <- check_file_existence(path) do
      read_and_parse_file(path)
    end
  end

  defp check_file_existence(config_path) do
    if File.exists?(config_path) do
      :ok
    else
      Logger.error("Failed to parse #{config_path} due to invalid_path")

      {:error, :invalid_path}
    end
  end

  defp read_and_parse_file(config_path) do
    config_path
    |> File.stream!([], :line)
    |> parse_file(config_path)
    |> handle_result()
  end

  defp handle_result(%State{result: result = {:ok, _}}), do: result

  defp handle_result(state = %State{result: {:error, reason}}) do
    Logger.error(
      "Failed to parse #{state.file_name} due to #{reason} at line #{state.line_number}",
      state: Map.from_struct(state)
    )

    state.result
  end

  defp parse_file(file_stream = %File.Stream{}, config_path) when is_binary(config_path) do
    Enum.reduce_while(file_stream, %State{file_name: config_path}, &parse_line/2)
  end

  # TODO: Implement the `:imports` reading
  defp parse_line(_line, state = %State{result: {:error, _}}) do
    {:halt, state}
  end

  defp parse_line(line, state = %State{line_number: line_number, result: {:ok, _}}) do
    line = strip_inline_comments(line)

    state =
      cond do
        can_skip_line?(line) ->
          %{state | line_number: line_number + 1}

        is_nil(Regex.run(@colon_definition_regex, line)) ->
          %{state | result: {:error, :invalid_format}}

        [_, key, value] = Regex.run(@colon_definition_regex, line) ->
          key = String.trim(key)
          value = String.trim(value)

          updated_state = State.define_config(state, key, value)
          %{updated_state | line_number: line_number + 1}
      end

    {:cont, state}
  end

  # Double slashes on a line define the start of a comment.
  # This removes the double slashes and anything following it.
  defp strip_inline_comments(line) do
    line
    |> String.split("//")
    |> List.first()
  end

  # Returns true if the parser can ignore the line passed in.
  # This is done if the line is a comment just whitespace
  defp can_skip_line?(line) do
    comment?(line) or empty?(line)
  end

  # Returns true if the line starts with double slashes
  defp comment?(line) do
    String.trim(line) =~ @double_slash_comment_regex
  end

  # Returns true if the line contains only whitespace
  defp empty?(line) do
    String.trim(line) == ""
  end
end
