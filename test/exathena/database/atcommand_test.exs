defmodule ExAthena.Database.AtCommandTest do
  use ExAthena.DataCase, async: true

  alias ExAthena.Database.AtCommand

  describe "changeset/2" do
    test "returns an valid changeset" do
      attrs = string_params_for(:atcommand)
      assert_changeset AtCommand.changeset(%AtCommand{}, attrs)
    end

    test "returns an invalid changeset" do
      changeset = refute_changeset AtCommand.changeset(%AtCommand{}, %{})

      assert errors_on(changeset) == %{command: ["can't be blank"]}
    end
  end
end
