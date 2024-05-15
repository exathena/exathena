defmodule ExAthena.Accounts.User do
  @moduledoc """
  The User schema representation.
  """
  use ExAthena, :schema

  @typep account_type :: :player | :server
  @typep role :: ExAthena.Database.Group.role()
  @typep sex :: :masculine | :feminine | :diverse

  @typedoc false
  @type t :: %__MODULE__{
          account_type: account_type(),
          birth_at: Date.t(),
          character_slots: non_neg_integer(),
          email: binary(),
          encrypted_email: binary(),
          password: String.t(),
          encrypted_web_auth_token: binary(),
          id: pos_integer(),
          inserted_at: NaiveDateTime.t(),
          password: String.t(),
          role: role(),
          session_count: non_neg_integer(),
          sex: sex(),
          updated_at: NaiveDateTime.t(),
          username: String.t(),
          web_auth_token: binary(),
          web_auth_token_enabled: boolean()
        }

  @fields ~w(
    id
    username
    password
    email
    account_type
    role
    sex
    birth_at
    session_count
    character_slots
    web_auth_token
    web_auth_token_enabled
  )a

  @required_fields ~w(
    username
    password
    email
    account_type
    role
  )a

  @allowed_account_type ~w(player server)a
  @allowed_role ExAthena.Database.Group.__allowed_roles__()
  @allowed_sex ~w(masculine feminine diverse)a

  schema "users" do
    field :username, :string
    field :password, :string
    field :email, Binary
    field :account_type, Ecto.Enum, values: @allowed_account_type, default: :player
    field :role, Ecto.Enum, values: @allowed_role, default: :player
    field :sex, Ecto.Enum, values: @allowed_sex, default: :masculine
    field :birth_at, :date
    field :session_count, :integer
    field :character_slots, :integer
    field :web_auth_token, Binary
    field :web_auth_token_enabled, :boolean, default: false

    # Encrypted fields
    field :encrypted_email, SHA256
    field :encrypted_web_auth_token, SHA256

    timestamps()
  end

  @doc """
  Generates the changeset for a given user.

  ## Examples

      iex> User.changeset(%User{}, %{
      ...>  username: "foo",
      ...>  password: "bar",
      ...>  email: "baz"
      ...> })
      %Ecto.Changeset{valid?: true}

      iex> User.changeset(%User{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(user = %__MODULE__{}, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:account_type, @allowed_account_type)
    |> validate_inclusion(:role, @allowed_role)
    |> validate_inclusion(:sex, @allowed_sex)
    |> unique_constraint(:username)
    |> unique_constraint(:encrypted_email)
    |> encrypt_fields()
    |> put_password()
  end

  defp encrypt_fields(changeset = %Changeset{}) do
    changeset
    |> put_change(:encrypted_web_auth_token, get_field(changeset, :web_auth_token))
    |> put_change(:encrypted_email, get_field(changeset, :email))
  end

  defp put_password(changeset = %Changeset{}) do
    case get_field(changeset, :password) do
      nil -> changeset
      "$pbkdf2" <> _password -> changeset
      password -> put_change(changeset, :password, Pbkdf2.hash_pwd_salt(password))
    end
  end
end
