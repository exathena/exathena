defmodule ExAthena.Accounts.BanTest do
  use ExAthena.DataCase

  alias ExAthena.Accounts.Ban

  describe "changeset/2" do
    test "returns a new valid changeset" do
      attrs = params_with_assocs(:ban)
      assert_changeset Ban.changeset(%Ban{}, attrs)
    end

    test "returns an invalid changeset" do
      changeset = refute_changeset Ban.changeset(%Ban{}, %{})

      assert %{banned_until: ["can't be blank"], user_id: ["can't be blank"]} ==
               errors_on(changeset)
    end
  end
end
