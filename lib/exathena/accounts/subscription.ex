defmodule ExAthena.Accounts.Subscription do
  @moduledoc """
  The Subscription schema representation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: Ecto.Schema.belongs_to(ExAthena.Accounts.User.t()),
          user_id: pos_integer(),
          until: Date.t(),
          inserted_at: NaiveDateTime.t()
        }

  schema "subscriptions" do
    field :until, :utc_datetime
    belongs_to :user, ExAthena.Accounts.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:user_id, :until])
    |> validate_required([:user_id, :until])
  end
end
