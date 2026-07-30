defmodule ExAthena.Accounts.BanTest do
  use ExAthena.DataCase, async: true

  alias ExAthena.Accounts.Ban

  describe "changeset/2" do
    test "returns a new valid changeset" do
      assert_changeset Ban.changeset(%Ban{user_id: 1}, %{
                         banned_until: NaiveDateTime.utc_now()
                       })
    end

    test "returns an invalid changeset" do
      changeset = refute_changeset Ban.changeset(%Ban{}, %{})

      assert errors_on(changeset) == %{
               banned_until: ["can't be blank"],
               user_id: ["can't be blank"]
             }
    end
  end
end
