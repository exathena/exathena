defmodule ExAthena.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use ExAthena, :context

  alias ExAthena.Accounts.{Ban, Subscription, User}
  alias ExAthena.Config
  alias ExAthena.Config.LoginAthena
  alias ExAthena.Database
  alias ExAthena.Database.Group

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
  # TODO: Check user state (wtf is this?)
  # TODO: Check user denylist
  # TODO: Check if char-server is up to return list of online servers
  @spec authorize_user(User.t()) :: :ok | {:error, :user_banned, DateTime.t()}
  def authorize_user(user = %User{}) do
    with :ok <- check_user_ban(user),
         :ok <- check_user_expiration_date(user) do
      check_user_role(user)
    end
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

  @doc """
  Checks if the given user is authorized to
  connect with his current role.

  ## Examples

      iex> check_user_role(%User{})
      :ok

      iex> check_user_role(%User{})
      {:error, :unauthorized}

      # When LoginAthenaConfig didn't start yet
      # or GroupsDb didn't start yet
      iex> check_user_role(%User{})
      {:error, :internal_server_error}

  """
  @spec check_user_role(User.t()) :: :ok | {:error, :unauthorized | :internal_server_error}
  def check_user_role(user = %User{}) do
    case Config.login_athena() do
      {:ok, %LoginAthena{min_group_id_to_connect: -1, group_id_to_connect: -1}} ->
        :ok

      {:ok, %LoginAthena{min_group_id_to_connect: -1, group_id_to_connect: group_id}} ->
        check_only_role(group_id, user)

      {:ok, %LoginAthena{min_group_id_to_connect: group_id, group_id_to_connect: -1}} ->
        check_min_role(group_id, user)

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  defp check_only_role(group_id, user) do
    case Database.get_by(PlayerGroupDb, role: user.role) do
      {:ok, %Group{id: ^group_id}} ->
        :ok

      {:ok, %Group{}} ->
        {:error, :unauthorized}

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  defp check_min_role(group_id, user) do
    case Database.get_by(PlayerGroupDb, role: user.role) do
      {:ok, %Group{id: current_group_id}} when current_group_id >= group_id ->
        :ok

      {:ok, %Group{}} ->
        {:error, :unauthorized}

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  @doc """
  Checks if the user is allowed to connect when
  server has the option `start_limited_time` activated.

  ## Examples

      iex> check_user_expiration_date(%User{})
      :ok

      iex> check_user_expiration_date(%User{})
      {:error, :access_expired}

      # When LoginAthenaConfig didn't start yet
      iex> check_user_expiration_date(%User{})
      {:error, :internal_server_error}

  """
  @spec check_user_expiration_date(User.t()) ::
          :ok | {:error, :access_expired | :internal_server_error}
  def check_user_expiration_date(user = %User{}) do
    case Config.login_athena() do
      {:ok, %LoginAthena{start_limited_time: -1}} ->
        :ok

      {:ok, %LoginAthena{start_limited_time: _}} ->
        do_check_user_expiration_date(user)

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  defp do_check_user_expiration_date(user = %User{}) do
    now = ExAthena.now()

    query =
      Subscription
      |> where([s], s.user_id == ^user.id)
      |> where([s], ^now <= s.until)

    case Repo.one(query) do
      nil -> {:error, :access_expired}
      %Subscription{} -> :ok
    end
  end
end
