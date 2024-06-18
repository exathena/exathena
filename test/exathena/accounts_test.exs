defmodule ExAthena.AccountsTest do
  use ExAthena.DataCase, async: false
  @moduletag capture_log: true

  alias ExAthena.Accounts
  alias ExAthena.Accounts.User
  alias ExAthena.{Config, Database}

  setup tags do
    case tags[:start_servers] do
      :all ->
        start_supervised(Config)
        start_supervised(Database)

      :config ->
        start_supervised(Config)

      :database ->
        start_supervised(Database)

      _ ->
        :noop
    end

    :ok
  end

  describe "get_user!/1" do
    test "throws an exception when user doesn't exist" do
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(123) end
    end

    test "returns an existing user" do
      id = insert(:user).id
      assert %User{id: ^id} = Accounts.get_user!(id)
    end
  end

  describe "get_user/1" do
    test "returns an error when user doesn't exist" do
      assert Accounts.get_user(123) == {:error, :not_found}
    end

    test "returns an existing user" do
      id = insert(:user).id
      assert {:ok, %User{id: ^id}} = Accounts.get_user(id)
    end
  end

  describe "get_user_by_username/1" do
    test "returns an error when user doesn't exist" do
      assert Accounts.get_user_by_username("username") == {:error, :not_found}
    end

    test "returns an existing user" do
      user = insert(:user)
      id = user.id

      assert {:ok, %User{id: ^id}} = Accounts.get_user_by_username(user.username)
    end
  end

  describe "create_user!/1" do
    test "throws an exception when changeset is invalid" do
      assert_raise Ecto.InvalidChangesetError, fn -> Accounts.create_user!(%{}) end
    end

    test "returns the new user" do
      attrs = params_for(:user)
      assert %User{} = Accounts.create_user!(attrs)
    end
  end

  describe "create_user/1" do
    test "returns an error when changeset is invalid" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Accounts.create_user(%{})
    end

    test "returns the new user" do
      attrs = params_for(:user)
      assert {:ok, %User{}} = Accounts.create_user(attrs)
    end
  end

  describe "update_user/2" do
    test "returns an error when changeset is invalid" do
      user = insert(:user)
      attrs = %{username: nil}

      assert {:error, %Ecto.Changeset{valid?: false}} = Accounts.update_user(user, attrs)
    end

    test "returns the updated user" do
      user = insert(:user)
      attrs = %{username: "foo"}

      assert {:ok, %User{username: "foo"}} = Accounts.update_user(user, attrs)
    end
  end

  describe "authenticate_user/2" do
    test "authenticates user with credentials are valid" do
      password = "123456789"
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))

      assert Accounts.authenticate_user(user, password) == :ok
    end

    test "authenticates server user with credentials are valid" do
      password = "123456789"
      user = insert(:user, account_type: :server, password: Pbkdf2.hash_pwd_salt(password))

      assert Accounts.authenticate_user(user, password) == :ok
    end

    test "returns error with invalid credentials" do
      user = insert(:user)

      assert Accounts.authenticate_user(user, "123456789") == {:error, :invalid_credentials}
    end
  end

  describe "authorize_user/1" do
    @tag start_servers: :all
    test "authorizes user when user isn't banned" do
      travel_to(Timex.now())

      user = insert(:user)
      assert Accounts.authorize_user(user) == :ok
    end

    @tag start_servers: :all
    test "authorizes server user when user isn't banned" do
      travel_to(Timex.now())

      user = insert(:user, account_type: :server)
      assert Accounts.authorize_user(user) == :ok
    end

    @tag start_servers: :all
    test "returns error with user banned" do
      user = insert(:user)
      banned_until = insert(:ban, user: user).banned_until

      travel_to(Timex.now())

      assert Accounts.authorize_user(user) == {:error, :user_banned, banned_until}
    end
  end

  describe "check_user_ban/1" do
    test "checks user ban and return ok" do
      travel_to(Timex.now())

      user = insert(:user)
      assert Accounts.check_user_ban(user) == :ok
    end

    test "checks user ban and return ok when he was banned" do
      user = insert(:user)
      banned_until = insert(:ban, user: user).banned_until

      travel_to(Timex.shift(banned_until, seconds: 1))

      assert Accounts.check_user_ban(user) == :ok
    end

    test "returns error with user banned" do
      user = insert(:user)
      banned_until = insert(:ban, user: user).banned_until

      travel_to(Timex.now())

      assert {:error, :user_banned, banned_until} == Accounts.check_user_ban(user)
    end
  end

  describe "check_user_role/1" do
    @tag start_servers: :all
    test "checks user role and return ok" do
      user = insert(:user)
      assert Accounts.check_user_role(user) == :ok
    end

    @tag start_servers: :all
    test "returns unauthorized if his role isn't allowed" do
      user = insert(:user)

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: 1}}
      end)

      assert Accounts.check_user_role(user) == {:error, :unauthorized}

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: -1, group_id_to_connect: 5}}
      end)

      assert Accounts.check_user_role(user) == {:error, :unauthorized}
    end

    @tag start_servers: :database
    test "returns error with login_athena isn't available yet" do
      user = insert(:user)
      assert Accounts.check_user_role(user) == {:error, :internal_server_error}
    end

    @tag start_servers: :config
    test "returns error with groups_db isn't available yet" do
      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: 1}}
      end)

      user = insert(:user)
      assert Accounts.check_user_role(user) == {:error, :internal_server_error}
    end
  end

  describe "check_user_expiration_date/1" do
    @tag start_servers: :config
    test "returns success when server isn't configured with user's expiration date" do
      user = insert(:user)
      assert Accounts.check_user_expiration_date(user) == :ok
    end

    @tag start_servers: :config
    test "returns success when current datetime is between subscription until datetime" do
      user = insert(:user)
      until = insert(:subscription, user: user).until
      travel_to(Timex.shift(until, days: -1))

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | start_limited_time: 1}}
      end)

      assert Accounts.check_user_expiration_date(user) == :ok
    end

    @tag start_servers: :config
    test "returns access expired if current datetime is greater than subscription until datetime" do
      user = insert(:user)
      until = insert(:subscription, user: user).until
      travel_to(Timex.shift(until, seconds: 1))

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | start_limited_time: 1}}
      end)

      assert Accounts.check_user_expiration_date(user) == {:error, :access_expired}
    end

    test "returns error with login_athena isn't available yet" do
      user = insert(:user)
      assert Accounts.check_user_expiration_date(user) == {:error, :internal_server_error}
    end
  end
end
