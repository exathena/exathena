defmodule ExAthena.Accounts.AuthenticationLog do
  @moduledoc """
  The authentication log schema representation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: Ecto.Schema.belongs_to(ExAthena.Accounts.User.t()),
          user_id: pos_integer(),
          ip_address: String.t(),
          message: String.t(),
          metadata: map(),
          inserted_at: NaiveDateTime.t()
        }

  schema "authentication_logs" do
    field :ip_address, ExAthena.Encrypted.Binary
    field :message, :string
    field :metadata, :map
    belongs_to :user, ExAthena.Accounts.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(authentication_log, attrs) do
    authentication_log
    |> cast(attrs, [:ip_address, :message, :metadata])
    |> validate_required([:ip_address, :message, :metadata])
  end
end
