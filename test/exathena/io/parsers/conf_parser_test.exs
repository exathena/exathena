defmodule ExAthena.IO.ConfParserTest do
  use ExAthena.DataCase, async: true
  @moduletag capture_log: true

  alias ExAthena.IO.ConfParser, as: Parser

  @relative_config_file "my_config.conf"
  @empty_config_file "empty.conf"
  @invalid_format_config_file "invalid_format.conf"
  @partial_valid_config_file "partial_valid_config.conf"
  @invalid_path_config_file "bar.conf"

  describe "parse_config/1" do
    test "parses the config from relative path" do
      assert Parser.parse_config(@relative_config_file) == {:ok, %{"bind_ip" => "127.0.0.1"}}
    end

    test "parses an empty file" do
      assert Parser.parse_config(@empty_config_file) == {:ok, %{}}
    end

    test "returns error when file has invalid format" do
      log =
        capture_log(fn ->
          assert Parser.parse_config(@invalid_format_config_file) == {:error, :invalid_format}
        end)

      assert log =~ "Failed to parse"
      assert log =~ @invalid_format_config_file
      assert log =~ "due to invalid_format at line 5"
    end

    test "returns error when one key is with invalid format" do
      log =
        capture_log(fn ->
          assert Parser.parse_config(@partial_valid_config_file) == {:error, :invalid_format}
        end)

      assert log =~ "Failed to parse"
      assert log =~ @partial_valid_config_file
      assert log =~ "due to invalid_format at line 170"
    end

    test "returns error when file doesn't exist" do
      log =
        capture_log(fn ->
          assert Parser.parse_config(@invalid_path_config_file) == {:error, :invalid_path}
        end)

      assert log =~ "Failed to parse"
      assert log =~ @invalid_path_config_file
      assert log =~ "due to invalid_path"
    end
  end
end
