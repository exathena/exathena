defmodule ExAthena.Accounts.Subscription do
  @moduledoc """
  The Subscription schema representation.
  """
  use ExAthena, :schema

  alias ExAthena.Accounts.User

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: required_assoc(User.t()),
          user_id: pos_integer(),
          until: Date.t(),
          inserted_at: NaiveDateTime.t()
        }

  schema "subscriptions" do
    field :until, :utc_datetime
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc """
  Generates the changeset for a given subscription.

  ## Examples

      iex> Subscription.changeset(%Subscription{}, %{user_id: 1, until: ~U[2024-02-01 00:00:00Z])
      %Ecto.Changeset{valid?: true}

      iex> User.changeset(%Subscription{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:user_id, :until])
    |> validate_required([:user_id, :until])
  end
end
