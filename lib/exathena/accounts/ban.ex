defmodule ExAthena.Accounts.Ban do
  @moduledoc """
  The Ban schema representation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: Ecto.Schema.belongs_to(ExAthena.Accounts.User.t()),
          user_id: pos_integer(),
          banned_until: Date.t(),
          inserted_at: NaiveDateTime.t()
        }

  @fields ~w(user_id banned_until)a

  schema "bans" do
    field :banned_until, :utc_datetime
    belongs_to :user, ExAthena.Accounts.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(ban, attrs) do
    ban
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
