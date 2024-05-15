defmodule ExAthena.Accounts.SubscriptionTest do
  use ExAthena.DataCase

  alias ExAthena.Accounts.Subscription

  describe "changeset/2" do
    test "returns a new valid changeset" do
      attrs = params_with_assocs(:subscription)
      assert_changeset Subscription.changeset(%Subscription{}, attrs)
    end

    test "returns an invalid changeset" do
      changeset = refute_changeset Subscription.changeset(%Subscription{}, %{})

      assert %{until: ["can't be blank"], user_id: ["can't be blank"]} ==
               errors_on(changeset)
    end
  end
end
