defmodule ExAthena.IO.ConfParserTest do
  use ExAthena.DataCase

  alias ExAthena.IO.ConfParser, as: Parser

  @relative_config_file "my_config.conf"
  @empty_config_file "empty.conf"
  @invalid_format_config_file "invalid_format.conf"
  @partial_valid_config_file "partial_valid_config.conf"
  @invalid_path_config_file "bar.conf"

  setup do
    old_path = Application.get_env(:exathena, :settings_path)
    Application.put_env(:exathena, :settings_path, "test/support")

    on_exit(fn -> Application.put_env(:exathena, :settings_path, old_path) end)

    :ok
  end

  describe "parse_config/1" do
    test "parses the config from relative path" do
      assert {:ok, %{"bind_ip" => "127.0.0.1"}} == Parser.parse_config(@relative_config_file)
    end

    test "parses an empty file" do
      assert {:ok, %{}} == Parser.parse_config(@empty_config_file)
    end

    @tag capture_log: true
    test "returns error when file has invalid format" do
      func = fn ->
        assert {:error, :invalid_format} == Parser.parse_config(@invalid_format_config_file)
      end

      assert capture_log(func) =~ "Failed to parse"
      assert capture_log(func) =~ @invalid_format_config_file
      assert capture_log(func) =~ "due to invalid_format at line 5"
    end

    @tag capture_log: true
    test "returns error when one key is with invalid format" do
      func = fn ->
        assert {:error, :invalid_format} == Parser.parse_config(@partial_valid_config_file)
      end

      assert capture_log(func) =~ "Failed to parse"
      assert capture_log(func) =~ @partial_valid_config_file
      assert capture_log(func) =~ "due to invalid_format at line 170"
    end

    test "returns error when file doesn't exist" do
      func = fn ->
        assert {:error, :invalid_path} == Parser.parse_config(@invalid_path_config_file)
      end

      assert capture_log(func) =~ "Failed to parse"
      assert capture_log(func) =~ @invalid_path_config_file
      assert capture_log(func) =~ "due to invalid_path"
    end
  end
end
