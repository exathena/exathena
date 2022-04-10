defmodule ExAthenaEvents.ProducerTest do
  use ExAthena.SocketCase

  alias ExAthenaEvents.Producer

  setup do
    Mox.stub_with(ExAthenaLoggerMock, FakeExAthenaLogger)

    :ok
  end

  test "user_authentication_requested/1 returns success after dispatching event", %{
    socket: socket
  } do
    assert :ok == Producer.user_authentication_requested(socket)
  end

  test "user_authentication_accepted/2 returns success after dispatching event", %{socket: socket} do
    user = insert(:user)

    assert :ok == Producer.user_authentication_accepted(socket, user)
  end

  test "user_authentication_rejected/2 returns success after dispatching event", %{socket: socket} do
    assert :ok == Producer.user_authentication_rejected(socket, :invalid_credentials)
  end
end
