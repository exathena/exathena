defmodule ExAthena.AccountsTest do
  use ExAthena.DataCase, async: true
  @moduletag capture_log: true
  @moduletag :skip

  alias ExAthena.Accounts

  describe "get_user!/1" do
    test "throws an exception when user doesn't exist" do
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(123) end
    end

    test "returns an existing user" do
      id = insert(:user).id
      assert %Accounts.User{id: ^id} = Accounts.get_user!(id)
    end
  end

  describe "get_user/1" do
    test "returns an error when user doesn't exist" do
      assert {:error, :not_found} == Accounts.get_user(123)
    end

    test "returns an existing user" do
      id = insert(:user).id
      assert {:ok, %Accounts.User{id: ^id}} = Accounts.get_user(id)
    end
  end

  describe "get_user_by_username/1" do
    test "returns an error when user doesn't exist" do
      assert {:error, :not_found} == Accounts.get_user_by_username("username")
    end

    test "returns an existing user" do
      user = insert(:user)
      id = user.id

      assert {:ok, %Accounts.User{id: ^id}} = Accounts.get_user_by_username(user.username)
    end
  end

  describe "create_user!/1" do
    test "throws an exception when changeset is invalid" do
      assert_raise Ecto.InvalidChangesetError, fn -> Accounts.create_user!(%{}) end
    end

    test "returns the new user" do
      attrs = params_for(:user)
      assert %Accounts.User{} = Accounts.create_user!(attrs)
    end
  end

  describe "create_user/1" do
    test "returns an error when changeset is invalid" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Accounts.create_user(%{})
    end

    test "returns the new user" do
      attrs = params_for(:user)
      assert {:ok, %Accounts.User{}} = Accounts.create_user(attrs)
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

      assert {:ok, %Accounts.User{username: "foo"}} = Accounts.update_user(user, attrs)
    end
  end

  describe "authenticate_user/2" do
    test "authenticates user with credentials are valid" do
      password = "123456789"
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))

      assert :ok == Accounts.authenticate_user(user, password)
    end

    test "authenticates server user with credentials are valid" do
      password = "123456789"
      user = insert(:user, account_type: :server, password: Pbkdf2.hash_pwd_salt(password))

      assert :ok == Accounts.authenticate_user(user, password)
    end

    test "returns error with invalid credentials" do
      user = insert(:user)

      assert {:error, :invalid_credentials} = Accounts.authenticate_user(user, "123456789")
    end
  end

  describe "authorize_user/1" do
    test "authorizes user when user isn't banned" do
      travel_to(Timex.now())

      user = insert(:user)
      assert :ok == Accounts.authorize_user(user)
    end

    test "authorizes server user when user isn't banned" do
      travel_to(Timex.now())

      user = insert(:user, account_type: :server)
      assert :ok == Accounts.authorize_user(user)
    end

    test "returns error with user banned" do
      user = insert(:user)
      banned_until = insert(:ban, user: user).banned_until

      travel_to(Timex.now())

      assert {:error, :user_banned, banned_until} == Accounts.authorize_user(user)
    end
  end

  describe "check_user_ban/1" do
    test "checks user ban and return ok" do
      travel_to(Timex.now())

      user = insert(:user)
      assert :ok == Accounts.check_user_ban(user)
    end

    test "checks user ban and return ok when he was banned" do
      user = insert(:user)
      banned_until = insert(:ban, user: user).banned_until

      travel_to(Timex.shift(banned_until, seconds: 1))

      assert :ok == Accounts.check_user_ban(user)
    end

    test "returns error with user banned" do
      user = insert(:user)
      banned_until = insert(:ban, user: user).banned_until

      travel_to(Timex.now())

      assert {:error, :user_banned, banned_until} == Accounts.check_user_ban(user)
    end
  end

  describe "check_user_role/1" do
    test "checks user role and return ok" do
      user = insert(:user)
      assert :ok == Accounts.check_user_role(user)
    end

    test "returns unauthorized if his role isn't allowed" do
      user = insert(:user)

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: 1}}
      end)

      assert {:error, :unauthorized} == Accounts.check_user_role(user)

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: -1, group_id_to_connect: 5}}
      end)

      assert {:error, :unauthorized} == Accounts.check_user_role(user)
    end

    test "returns error with login_athena isn't available yet" do
      user = insert(:user)
      assert {:error, :internal_server_error} == Accounts.check_user_role(user)
    end

    test "returns error with groups_db isn't available yet" do
      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: 1}}
      end)

      user = insert(:user)
      assert {:error, :internal_server_error} == Accounts.check_user_role(user)
    end
  end

  describe "check_user_expiration_date/1" do
    test "returns success when server isn't configured with user's expiration date" do
      user = insert(:user)
      assert :ok == Accounts.check_user_expiration_date(user)
    end

    test "returns success when current datetime is between subscription until datetime" do
      user = insert(:user)
      until = insert(:subscription, user: user).until
      travel_to(Timex.shift(until, days: -1))

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | start_limited_time: 1}}
      end)

      assert :ok == Accounts.check_user_expiration_date(user)
    end

    test "returns access expired if current datetime is greater than subscription until datetime" do
      user = insert(:user)
      until = insert(:subscription, user: user).until
      travel_to(Timex.shift(until, seconds: 1))

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | start_limited_time: 1}}
      end)

      assert {:error, :access_expired} == Accounts.check_user_expiration_date(user)
    end

    test "returns error with login_athena isn't available yet" do
      user = insert(:user)
      assert {:error, :internal_server_error} == Accounts.check_user_expiration_date(user)
    end
  end
end
