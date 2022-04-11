defmodule ExAthena.Config.ParserTest do
  use ExAthena.DataCase

  alias ExAthena.Config.Parser

  @relative_config_file "./test/support/settings/my_config.conf"
  @empty_config_file "./test/support/settings/empty.conf"
  @invalid_format_config_file "./test/support/settings/invalid_format.conf"
  @partial_valid_config_file "./test/support/settings/partial_valid_config.conf"
  @invalid_path_config_file "./foo/bar.conf"

  describe "parse_config/1" do
    test "parses the config from relative path" do
      assert {:ok, %{"bind_ip" => "127.0.0.1"}} == Parser.parse_config(@relative_config_file)
    end

    test "parses the config from full path" do
      full_path =
        @relative_config_file
        |> Path.expand()
        |> Path.absname()

      assert {:ok, %{"bind_ip" => "127.0.0.1"}} == Parser.parse_config(full_path)
    end

    test "parses an empty file" do
      assert {:ok, %{}} == Parser.parse_config(@empty_config_file)
    end

    @tag capture_log: true
    test "returns error when file has invalid format" do
      func = fn ->
        assert {:error, :invalid_format} == Parser.parse_config(@invalid_format_config_file)
      end

      expected_message =
        "Failed to parse #{@invalid_format_config_file} due to invalid_format at line 5"

      assert capture_log(func) =~ expected_message
    end

    @tag capture_log: true
    test "returns error when one key is with invalid format" do
      func = fn ->
        assert {:error, :invalid_format} == Parser.parse_config(@partial_valid_config_file)
      end

      expected_message =
        "Failed to parse #{@partial_valid_config_file} due to invalid_format at line 170"

      assert capture_log(func) =~ expected_message
    end

    test "returns error when file doesn't exist" do
      assert {:error, :invalid_path} == Parser.parse_config(@invalid_path_config_file)
    end
  end
end
