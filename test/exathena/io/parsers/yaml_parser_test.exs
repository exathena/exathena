defmodule ExAthena.IO.YamlParserTest do
  use ExAthena.DataCase, async: true
  @moduletag capture_log: true

  alias ExAthena.IO.YamlParser, as: Parser

  @group_db "groups_db.yml"
  @invalid_path_db "foo.yml"
  @invalid_format_db "invalid_format.yml"

  describe "parse_yaml/1" do
    test "parses the YAML database from given module" do
      assert {:ok, [%{"Id" => 0, "Name" => "Player"} | _]} = Parser.parse_yaml(@group_db)
    end

    test "returns error when file doesn't exist" do
      log =
        capture_log(fn ->
          assert Parser.parse_yaml(@invalid_path_db) == {:error, :invalid_path}
        end)

      assert log =~ "Failed to parse"
      assert log =~ @invalid_path_db
      assert log =~ "due to invalid_path"
    end

    test "returns error when file has invalid format" do
      log =
        capture_log(fn ->
          assert Parser.parse_yaml(@invalid_format_db) == {:error, :invalid_format}
        end)

      assert log =~ "Failed to parse"
      assert log =~ @invalid_format_db
      assert log =~ "due to invalid_format"
    end
  end
end
