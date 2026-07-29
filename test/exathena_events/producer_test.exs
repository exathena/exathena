defmodule ExAthenaEvents.ProducerTest do
  use ExAthenaWeb.ChannelCase, async: true

  alias ExAthenaEvents.Producer
  alias ExAthenaWeb.LoginChannel

  test "user_authentication_requested/1 returns success after dispatching event" do
    socket = join_public_channel(LoginChannel, "login")
    assert :ok == Producer.user_authentication_requested(socket)
  end

  test "user_authentication_accepted/2 returns success after dispatching event" do
    socket = join_public_channel(LoginChannel, "login")
    user = insert(:user)

    assert :ok == Producer.user_authentication_accepted(socket, user)
  end

  test "user_authentication_rejected/2 returns success after dispatching event" do
    socket = join_public_channel(LoginChannel, "login")
    assert :ok == Producer.user_authentication_rejected(socket, :invalid_credentials)
  end
end
