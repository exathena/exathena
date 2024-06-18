defmodule ExAthena.Config.LoginAthenaTest do
  use ExAthena.DataCase, async: true

  alias ExAthena.Config.LoginAthena

  describe "changeset/2" do
    test "returns a valid changeset" do
      attrs = params_for(:login_athena)
      assert_changeset LoginAthena.changeset(%LoginAthena{}, attrs)
    end

    test "returns an invalid changeset" do
      attrs =
        for {k, _} <- params_for(:login_athena),
            into: %{},
            do: {k, nil}

      refute_changeset LoginAthena.changeset(%LoginAthena{}, attrs)
    end
  end
end
