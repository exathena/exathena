defmodule ExAthena.IO.ParserTest do
  use ExAthena.DataCase

  require TemporaryEnv

  alias ExAthena.Config.LoginAthena
  alias ExAthena.Database.Group
  alias ExAthena.IO.Parser

  describe "load/2 with .conf files" do
    test "returns the conf file parsed into the given schema" do
      assert {:ok, %LoginAthena{}} = Parser.load(:conf, LoginAthena)
    end

    test "returns error when changeset is invalid" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Parser.load(:conf, InvalidConfig)
    end

    @tag capture_log: true
    test "returns error when file has invalid path" do
      log =
        capture_log(fn ->
          assert Parser.load(:conf, InvalidPathConfig) == {:error, :invalid_path}
        end)

      assert log =~ "Failed to parse"
      assert log =~ "conf/foo.conf"
      assert log =~ "due to invalid_path"
    end

    @tag capture_log: true
    test "returns error when file has invalid format" do
      log =
        capture_log(fn ->
          assert Parser.load(:conf, InvalidFormatConfig) == {:error, :invalid_format}
        end)

      assert log =~ "Failed to parse"
      assert log =~ "conf/partial_valid_config.conf"
      assert log =~ "due to invalid_format at line 170"
    end
  end

  describe "load/2 with .yml files" do
    test "returns the yml file parsed into the given schema" do
      assert {:ok, [%Group{} | _]} = Parser.load(:yaml, Group)
    end

    test "returns error when changeset is invalid" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Parser.load(:yaml, InvalidDatabase)
    end

    @tag capture_log: true
    test "returns error when file has invalid path" do
      log =
        capture_log(fn ->
          assert Parser.load(:yaml, InvalidPathDatabase) == {:error, :invalid_path}
        end)

      assert log =~ "Failed to parse"
      assert log =~ "database/foo.yml"
      assert log =~ "due to invalid_path"
    end

    @tag capture_log: true
    test "returns error when file has invalid format" do
      log =
        capture_log(fn ->
          assert Parser.load(:yaml, InvalidFormatDatabase) == {:error, :invalid_format}
        end)

      assert log =~ "Failed to parse"
      assert log =~ "database/invalid_format.yml"
      assert log =~ "due to invalid_format"
    end
  end
end
