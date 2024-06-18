defmodule ExAthena.Database.GroupTest do
  use ExAthena.DataCase, async: true

  alias ExAthena.Database.Group

  describe "changeset/2" do
    test "returns an valid changeset" do
      attrs = string_params_for(:group)
      assert_changeset Group.changeset(%Group{}, attrs)
    end

    test "returns an invalid changeset" do
      changeset = refute_changeset Group.changeset(%Group{}, %{})

      assert errors_on(changeset) == %{
               id: ["can't be blank"],
               name: ["can't be blank"],
               role: ["can't be blank"]
             }
    end

    test "returns an invalid changeset with invalid role" do
      attrs = string_params_for(:group, role: :foo)
      changeset = refute_changeset Group.changeset(%Group{}, attrs)

      assert "is invalid" in errors_on(changeset).role
    end
  end
end
