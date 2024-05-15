defmodule ExAthena.DatabaseTest do
  use ExAthena.DataCase

  alias ExAthena.Database
  alias ExAthena.Database.Group

  setup do
    start_supervised!(Database)
    :ok
  end

  describe "all" do
    test "returns all groups" do
      assert [%Group{} | _] = Database.all(PlayerGroupDb)
    end

    test "returns all groups from filter" do
      assert [%Group{id: 0, name: "Player"}] = Database.all(PlayerGroupDb, name: "Player")
    end
  end

  describe "get/1" do
    test "returns one group from given id" do
      assert {:ok, %Group{id: 0, name: "Player"}} = Database.get(PlayerGroupDb, 0)
    end

    test "returns error when group doesn't exist" do
      assert {:error, :not_found} = Database.get(PlayerGroupDb, -1)
    end
  end

  describe "get_by/1" do
    test "returns one group from given filter" do
      assert {:ok, %Group{id: 0, name: "Player"}} = Database.get_by(PlayerGroupDb, role: :player)
    end

    test "returns error when group doesn't exist" do
      assert {:error, :not_found} = Database.get_by(PlayerGroupDb, id: -1)
    end
  end
end
