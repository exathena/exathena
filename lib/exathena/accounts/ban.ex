defmodule ExAthena.Accounts.Ban do
  @moduledoc """
  The Ban schema representation.
  """
  use ExAthena, :schema

  alias ExAthena.Accounts.User

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: required_assoc(User.t()),
          user_id: pos_integer(),
          banned_until: Date.t(),
          inserted_at: NaiveDateTime.t()
        }

  @fields ~w(user_id banned_until)a

  schema "bans" do
    field :banned_until, :utc_datetime
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(ban, attrs) do
    ban
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
