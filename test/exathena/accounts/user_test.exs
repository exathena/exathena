defmodule ExAthena.Accounts.UserTest do
  use ExAthena.DataCase, async: true

  alias ExAthena.Accounts.User

  describe "changeset/2" do
    test "returns a new valid changeset" do
      attrs = params_for(:user)
      assert_changeset User.changeset(%User{}, attrs)
    end

    test "returns an invalid changeset" do
      changeset = refute_changeset User.changeset(%User{}, %{})

      assert errors_on(changeset) == %{
               email: ["can't be blank"],
               password: ["can't be blank"],
               username: ["can't be blank"]
             }
    end

    test "returns an valid changeset with salted password" do
      password = "123456789"
      attrs = params_for(:user, password: password)
      changeset = assert_changeset User.changeset(%User{}, attrs)

      refute get_field(changeset, :password) == password
    end
  end
end
