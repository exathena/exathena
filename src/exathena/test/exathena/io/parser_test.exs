defmodule ExAthena.IO.ParserTest do
  use ExAthena.DataCase

  require TemporaryEnv

  alias ExAthena.Config.LoginAthena
  alias ExAthena.IO.Parser

  describe "load/2" do
    test "returns the conf file parsed into the given schema" do
      assert {:ok, %LoginAthena{}} = Parser.load(:conf, LoginAthena)
    end

    test "returns error when changeset is invalid" do
      TemporaryEnv.put :exathena, :settings_path, "test/support" do
        assert {:error, %Ecto.Changeset{valid?: false}} = Parser.load(:conf, InvalidConfig)
      end
    end

    @tag capture_log: true
    test "returns error when file has invalid path" do
      assert capture_log(fn ->
               assert {:error, :invalid_path} = Parser.load(:conf, InvalidFormatConfig)
             end) =~ "due to invalid_path"
    end

    @tag capture_log: true
    test "returns error when file has invalid format" do
      TemporaryEnv.put :exathena, :settings_path, "test/support" do
        assert capture_log(fn ->
                 assert {:error, :invalid_format} = Parser.load(:conf, InvalidFormatConfig)
               end) =~ "due to invalid_format"
      end
    end
  end
end
