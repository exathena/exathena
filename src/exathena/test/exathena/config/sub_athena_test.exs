defmodule ExAthena.Config.SubnetAthenaTest do
  use ExAthena.DataCase

  alias ExAthena.Config.SubnetAthena

  describe "changeset/2" do
    test "returns a valid changeset" do
      attrs = params_for(:subnet_athena)
      assert_changeset SubnetAthena.changeset(%SubnetAthena{}, attrs)
    end

    test "returns an invalid changeset" do
      attrs =
        for {k, _} <- params_for(:subnet_athena),
            into: %{},
            do: {k, nil}

      refute_changeset SubnetAthena.changeset(%SubnetAthena{}, attrs)
    end
  end
end
