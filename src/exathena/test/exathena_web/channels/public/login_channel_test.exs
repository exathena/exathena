defmodule ExAthenaWeb.LoginChannelTest do
  use ExAthenaWeb.ChannelCase, async: true

  alias ExAthena.{Config, Database}
  alias ExAthenaWeb.LoginChannel

  setup do
    Mox.stub_with(ExAthenaEventsMock, FakeExAthenaEvents)

    :ok
  end

  test "connects to the channel" do
    join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})
    assert_receive :login_join
  end

  describe "authentication topic" do
    test "sign in user" do
      start_supervised!(Config)
      start_supervised!(Database)
      freeze_time()

      password = Faker.String.base64()
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))
      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_accepted", %{}
    end

    test "reject banned user" do
      travel_to(~U[2022-06-17 20:39:14Z])

      password = Faker.String.base64()
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))
      insert(:ban, user: user, banned_until: ~U[2022-07-17 23:39:14Z])

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{
        errors: %{detail: "Your account is banned until 2022-07-17 23:39:14Z"}
      }
    end

    test "reject invalid credentials" do
      freeze_time()

      password = Faker.String.base64()
      user = insert(:user)

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{errors: %{detail: "Invalid Credentials"}}
    end

    test "reject access expired" do
      start_supervised!(Config)

      password = Faker.String.base64()
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))
      until = insert(:subscription, user: user).until
      travel_to(Timex.shift(until, seconds: 1), 2)

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | start_limited_time: 1}}
      end)

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{errors: %{detail: "Your access expired"}}
    end

    test "reject minimum role" do
      start_supervised!(Config)
      start_supervised!(Database)
      freeze_time()

      password = Faker.String.base64()
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | min_group_id_to_connect: 1}}
      end)

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{errors: %{detail: "Unauthorized"}}
    end

    test "reject only role" do
      start_supervised!(Config)
      start_supervised!(Database)
      freeze_time()

      password = Faker.String.base64()
      user = insert(:user, role: :admin, password: Pbkdf2.hash_pwd_salt(password))

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | group_id_to_connect: 1}}
      end)

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{errors: %{detail: "Unauthorized"}}
    end

    test "reject denied ip" do
      start_supervised!(Config)
      start_supervised!(Database)
      freeze_time()

      password = Faker.String.base64()
      user = insert(:user, password: Pbkdf2.hash_pwd_salt(password))
      denylist = ["200.120.10.67"]

      :sys.replace_state(LoginAthenaConfig, fn state ->
        %{state | data: %{state.data | use_dnsbl: true, dnsbl_servers: denylist}}
      end)

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{errors: %{detail: "User's IP is denylisted"}}
    end

    test "reject if server didn't start configs/databases" do
      freeze_time()

      password = Faker.String.base64()
      user = insert(:user, role: :admin, password: Pbkdf2.hash_pwd_salt(password))

      socket = join_public_channel(LoginChannel, "login", socket_payload: %{pid: self()})

      credentials = %{"username" => user.username, "password" => password}
      push(socket, "authentication", credentials)

      assert_receive {:authentication, ^credentials}

      assert_push "authentication_rejected", %{errors: %{detail: "Internal Server Error"}}
    end
  end
end
