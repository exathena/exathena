defmodule ExAthenaEventsTest do
  use ExAthenaWeb.ChannelCase

  alias ExAthenaWeb.LoginChannel

  setup do
    Mox.stub_with(ExAthenaLoggerMock, FakeExAthenaLogger)

    :ok
  end

  describe "user_authentication_requested/1" do
    test "returns error when can't dispatch event" do
      socket = join_public_channel(LoginChannel, "login")

      Mox.expect(ExAthenaEventsMock, :user_authentication_requested, fn ^socket ->
        {:error, "some error"}
      end)

      assert {:error, _} = ExAthenaEvents.user_authentication_requested(socket)
    end

    test "returns success after dispatching event" do
      socket = join_public_channel(LoginChannel, "login")
      Mox.expect(ExAthenaEventsMock, :user_authentication_requested, fn ^socket -> :ok end)

      assert :ok == ExAthenaEvents.user_authentication_requested(socket)
    end
  end

  describe "user_authentication_accepted/2" do
    test "returns error when can't dispatch event" do
      socket = join_public_channel(LoginChannel, "login")
      user = insert(:user)

      Mox.expect(ExAthenaEventsMock, :user_authentication_accepted, fn ^socket, ^user ->
        {:error, "some error"}
      end)

      assert {:error, _} = ExAthenaEvents.user_authentication_accepted(socket, user)
    end

    test "returns success after dispatching event" do
      socket = join_public_channel(LoginChannel, "login")
      user = insert(:user)

      Mox.expect(ExAthenaEventsMock, :user_authentication_accepted, fn ^socket, ^user -> :ok end)

      assert :ok == ExAthenaEvents.user_authentication_accepted(socket, user)
    end
  end

  describe "user_authentication_rejected/2" do
    test "returns error when can't dispatch event" do
      socket = join_public_channel(LoginChannel, "login")

      Mox.expect(ExAthenaEventsMock, :user_authentication_rejected, fn ^socket, _ ->
        {:error, "some error"}
      end)

      assert {:error, _} = ExAthenaEvents.user_authentication_rejected(socket, :foo)
    end

    test "returns success after dispatching event" do
      socket = join_public_channel(LoginChannel, "login")

      Mox.expect(ExAthenaEventsMock, :user_authentication_rejected, fn ^socket, :foo -> :ok end)

      assert :ok == ExAthenaEvents.user_authentication_rejected(socket, :foo)
    end
  end
end
