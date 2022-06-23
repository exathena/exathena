defmodule ExAthenaLogger.Sql.AuthenticationLog do
  @moduledoc """
  The authentication log schema representation.
  """
  use ExAthena, :schema

  alias ExAthena.Accounts.User

  @typedoc false
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: required_assoc(User.t()),
          user_id: pos_integer(),
          join_ref: non_neg_integer(),
          ip: binary(),
          encrypted_ip: binary(),
          message: String.t(),
          metadata: map(),
          inserted_at: NaiveDateTime.t()
        }

  @fields ~w(user_id join_ref ip message metadata)a
  @required_fields @fields -- ~w(user_id)a

  schema "authentication_logs" do
    field :join_ref, :integer
    field :ip, Binary
    field :message, :string
    field :metadata, :map

    # Encrypted fields
    field :encrypted_ip, SHA256

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc """
  Generates the changeset for a given authentication log.

  ## Examples

      iex> AuthenticationLog.changeset(%AuthenticationLog{}, valid_attrs)
      %Ecto.Changeset{valid?: true}

      iex> AuthenticationLog.changeset(%AuthenticationLog{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(authentication_log = %__MODULE__{}, attrs) do
    authentication_log
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> encrypt_fields()
  end

  defp encrypt_fields(changeset = %Changeset{}) do
    put_change(changeset, :encrypted_ip, get_field(changeset, :ip))
  end
end
