defmodule ExAthenaLogger.Sql.AuthenticationLog do
  @moduledoc """
  The authentication log schema representation.
  """
  use ExAthena, :schema

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: Ecto.Schema.belongs_to(ExAthena.Accounts.User.t()),
          user_id: pos_integer(),
          join_ref: non_neg_integer(),
          ip: binary(),
          encrypted_ip: binary(),
          message: String.t(),
          metadata: map(),
          inserted_at: NaiveDateTime.t()
        }

  schema "authentication_logs" do
    field :join_ref, :integer
    field :ip, ExAthena.Encrypted.Binary
    field :message, :string
    field :metadata, :map

    # Encrypted fields
    field :encrypted_ip, Cloak.Ecto.SHA256

    belongs_to :user, ExAthena.Accounts.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(authentication_log, attrs) do
    authentication_log
    |> cast(attrs, [:user_id, :join_ref, :ip, :message, :metadata])
    |> validate_required([:join_ref, :ip, :message, :metadata])
    |> encrypt_fields()
  end

  defp encrypt_fields(changeset) do
    put_change(changeset, :encrypted_ip, get_field(changeset, :ip))
  end
end
