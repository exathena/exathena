defmodule ExAthena.Config.LoginAthenaTest do
  use ExAthena.DataCase

  alias ExAthena.Config.LoginAthena

  describe "changeset/2" do
    test "returns a valid changeset" do
      attrs = params_for(:login_athena)
      assert_changeset LoginAthena.changeset(%LoginAthena{}, attrs)
    end

    test "returns an invalid changeset" do
      refute_changeset LoginAthena.changeset(%LoginAthena{}, %{})
    end
  end
end
