defmodule ExAthena.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use ExAthena, :context

  alias ExAthena.Accounts.{Ban, User}

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(pos_integer()) :: User.t() | no_return()
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      {:ok, %User{}}

      iex> get_user(456)
      {:error, :not_found}

  """
  @spec get_user(pos_integer()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Gets a single user by given username.

  ## Examples

      iex> get_user_by_username("foo")
      {:ok, %User{}}

      iex> get_user_by_username("bar")
      {:error, :not_found}

  """
  @spec get_user_by_username(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_by_username(username) do
    case Repo.get_by(User, username: username) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a user.

  Raises `Ecto.ChangeError` if the given attributes results into
  an invalid `Ecto.Changeset`.

  ## Examples

      iex> create_user!(%{field: value})
      %User{}

      iex> create_user!(%{field: bad_value})
      ** (Ecto.InvalidChangesetError)

  """
  @spec create_user!(map()) :: User.t()
  def create_user!(attrs \\ %{}) when is_map(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Creates an user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) when is_map(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an user.

  ## Examples

      iex> update_user(%User{}, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(user = %User{}, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Authenticates an user.

  ## Examples

      iex> authenticate_user(%User{}, "some password")
      :ok

      iex> authenticate_user(%User{}, "some password")
      {:error, :invalid_credentials}

  """
  @spec authenticate_user(User.t(), String.t()) :: :ok | {:error, :invalid_credentials}
  def authenticate_user(%User{password: user_password}, password) do
    if Pbkdf2.verify_pass(password, user_password) do
      :ok
    else
      {:error, :invalid_credentials}
    end
  end

  @doc """
  Authorizes an user.

  ## Examples

      iex> authenticate_user(%User{})
      :ok

      iex> authenticate_user(%User{})
      {:error, :user_banned, ~U[2022-04-07 16:37:44.783000Z]}

  """
  @spec authorize_user(User.t()) :: :ok | {:error, :user_banned, DateTime.t()}
  def authorize_user(user = %User{}) do
    check_user_ban(user)
  end

  @doc """
  Checks if the given user is banned.

  ## Examples

      iex> check_user_ban(%User{})
      :ok

      iex> check_user_ban(%User{})
      {:error, :user_banned, ~U[2022-04-07 16:37:44.783000Z]}

  """
  @spec check_user_ban(User.t()) :: :ok | {:error, :user_banned, DateTime.t()}
  def check_user_ban(user = %User{}) do
    now = ExAthena.now()

    query =
      Ban
      |> where([b], b.user_id == ^user.id)
      |> where([b], ^now <= b.banned_until)

    case Repo.one(query) do
      nil -> :ok
      %Ban{banned_until: banned_until} -> {:error, :user_banned, banned_until}
    end
  end
end
