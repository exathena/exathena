defmodule ExAthena.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use ExAthena, :context

  alias ExAthena.{Accounts, Config, Database}

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the Accounts.User does not exist.

  ## Examples

      iex> get_user!(123)
      %Accounts.User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(pos_integer()) :: Accounts.User.t() | no_return()
  def get_user!(id), do: Repo.get!(Accounts.User, id)

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      {:ok, %Accounts.User{}}

      iex> get_user(456)
      {:error, :not_found}

  """
  @spec get_user(pos_integer()) :: {:ok, Accounts.User.t()} | {:error, :not_found}
  def get_user(id) do
    if user = Repo.get(Accounts.User, id) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Gets a single user by given username.

  ## Examples

      iex> get_user_by_username("foo")
      {:ok, %Accounts.User{}}

      iex> get_user_by_username("bar")
      {:error, :not_found}

  """
  @spec get_user_by_username(String.t()) :: {:ok, Accounts.User.t()} | {:error, :not_found}
  def get_user_by_username(username) do
    if user = Repo.get_by(Accounts.User, username: username) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Creates a user.

  Raises `Ecto.ChangeError` if the given attributes results into
  an invalid `Ecto.Changeset`.

  ## Examples

      iex> create_user!(%{field: value})
      %Accounts.User{}

      iex> create_user!(%{field: bad_value})
      ** (Ecto.InvalidChangesetError)

  """
  @spec create_user!(map()) :: Accounts.User.t()
  def create_user!(attrs \\ %{}) when is_map(attrs) do
    %Accounts.User{}
    |> Accounts.User.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Creates an user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %Accounts.User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map()) :: {:ok, Accounts.User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) when is_map(attrs) do
    %Accounts.User{}
    |> Accounts.User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an user.

  ## Examples

      iex> update_user(%Accounts.User{}, %{field: new_value})
      {:ok, %Accounts.User{}}

      iex> update_user(%Accounts.User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(Accounts.User.t(), map()) ::
          {:ok, Accounts.User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(user = %Accounts.User{}, attrs) do
    user
    |> Accounts.User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Authenticates an user.

  ## Examples

      iex> authenticate_user(%Accounts.User{}, "some password")
      :ok

      iex> authenticate_user(%Accounts.User{}, "some password")
      {:error, :invalid_credentials}

  """
  @spec authenticate_user(Accounts.User.t(), String.t()) :: :ok | {:error, :invalid_credentials}
  def authenticate_user(%Accounts.User{password: user_password}, password) do
    if Pbkdf2.verify_pass(password, user_password) do
      :ok
    else
      {:error, :invalid_credentials}
    end
  end

  @doc """
  Authorizes an user.

  ## Examples

      iex> authenticate_user(%Accounts.User{})
      :ok

      iex> authenticate_user(%Accounts.User{})
      {:error, :user_banned, ~U[2022-04-07 16:37:44.783000Z]}

  """
  @spec authorize_user(Accounts.User.t()) ::
          :ok | {:error, :access_expired | :unauthorized} | {:error, :user_banned, DateTime.t()}
  def authorize_user(user = %Accounts.User{}) do
    with :ok <- check_user_ban(user),
         :ok <- check_user_expiration_date(user) do
      check_user_role(user)
    end
  end

  @doc """
  Checks if the given user is banned.

  ## Examples

      iex> check_user_ban(%Accounts.User{})
      :ok

      iex> check_user_ban(%Accounts.User{})
      {:error, :user_banned, ~U[2022-04-07 16:37:44.783000Z]}

  """
  @spec check_user_ban(Accounts.User.t()) :: :ok | {:error, :user_banned, DateTime.t()}
  def check_user_ban(user = %Accounts.User{}) do
    now = ExAthena.now()

    query =
      Accounts.Ban
      |> where([b], b.user_id == ^user.id)
      |> where([b], ^now <= b.banned_until)

    if ban = Repo.one(query) do
      {:error, :user_banned, ban.banned_until}
    else
      :ok
    end
  end

  @doc """
  Checks if the given user is authorized to
  connect with his current role.

  ## Examples

      iex> check_user_role(%Accounts.User{})
      :ok

      iex> check_user_role(%Accounts.User{})
      {:error, :unauthorized}

      # When LoginAthenaConfig didn't start yet
      # or GroupsDb didn't start yet
      iex> check_user_role(%Accounts.User{})
      {:error, :internal_server_error}

  """
  @spec check_user_role(Accounts.User.t()) ::
          :ok | {:error, :unauthorized | :internal_server_error}
  def check_user_role(user = %Accounts.User{}) do
    case Config.login_athena() do
      {:ok, %{min_group_id_to_connect: -1, group_id_to_connect: -1}} ->
        :ok

      {:ok, %{min_group_id_to_connect: -1, group_id_to_connect: group_id}} ->
        check_only_role(group_id, user)

      {:ok, %{min_group_id_to_connect: group_id, group_id_to_connect: -1}} ->
        check_min_role(group_id, user)

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  defp check_only_role(group_id, user) do
    case Database.get_by(PlayerGroupDb, role: user.role) do
      {:ok, %Database.Group{id: ^group_id}} -> :ok
      {:ok, %Database.Group{}} -> {:error, :unauthorized}
      {:error, _} -> {:error, :internal_server_error}
    end
  end

  defp check_min_role(group_id, user) do
    case Database.get_by(PlayerGroupDb, role: user.role) do
      {:ok, %Database.Group{id: id}} when id >= group_id -> :ok
      {:ok, %Database.Group{}} -> {:error, :unauthorized}
      {:error, _} -> {:error, :internal_server_error}
    end
  end

  @doc """
  Checks if the user is allowed to connect when
  server has the option `start_limited_time` activated.

  ## Examples

      iex> check_user_expiration_date(%Accounts.User{})
      :ok

      iex> check_user_expiration_date(%Accounts.User{})
      {:error, :access_expired}

      # When LoginAthenaConfig didn't start yet
      iex> check_user_expiration_date(%Accounts.User{})
      {:error, :internal_server_error}

  """
  @spec check_user_expiration_date(Accounts.User.t()) ::
          :ok | {:error, :access_expired | :internal_server_error}
  def check_user_expiration_date(user = %Accounts.User{}) do
    case Config.login_athena() do
      {:ok, %{start_limited_time: -1}} -> :ok
      {:ok, %{start_limited_time: _}} -> do_check_user_expiration_date(user)
      {:error, _} -> {:error, :internal_server_error}
    end
  end

  defp do_check_user_expiration_date(user = %Accounts.User{}) do
    now = ExAthena.now()

    query =
      Accounts.Subscription
      |> where([s], s.user_id == ^user.id)
      |> where([s], ^now <= s.until)

    if Repo.one(query) do
      :ok
    else
      {:error, :access_expired}
    end
  end
end
