defmodule ExAthena.IO.YamlParserTest do
  use ExAthena.DataCase
  @moduletag capture_log: true

  alias ExAthena.IO.YamlParser, as: Parser

  @group_db "groups_db.yml"
  @invalid_path_db "foo.yml"
  @invalid_format_db "invalid_format.yml"

  setup do
    old_path = Application.get_env(:exathena, :database_path)
    Application.put_env(:exathena, :database_path, "test/support")

    on_exit(fn -> Application.put_env(:exathena, :database_path, old_path) end)

    :ok
  end

  describe "parse_yaml/1" do
    test "parses the YAML database from given module" do
      assert {:ok, [%{"Id" => 0, "Name" => "Player"} | _]} = Parser.parse_yaml(@group_db)
    end

    test "returns error when file doesn't exist" do
      assert capture_log(fn ->
               assert {:error, :invalid_path} == Parser.parse_yaml(@invalid_path_db)
             end) =~ "The given YAML file doesn't not exist"
    end

    test "returns error when file has invalid format" do
      assert capture_log(fn ->
               assert {:error, :invalid_format} == Parser.parse_yaml(@invalid_format_db)
             end) =~ "Failed to parse YAML file"
    end
  end
end
