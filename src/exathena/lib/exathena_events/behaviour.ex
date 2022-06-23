defmodule ExAthenaEvents.Behaviour do
  @moduledoc """
  The ExAthena Events behaviour.

  It exports the events callbacks that should be
  dispatched by the behaviour caller.
  """

  alias ExAthena.Accounts.User

  # The socket type
  @typep socket :: Phoenix.Socket.t()

  @doc """
  After an User request authentication, this
  event is dispatched to generate an
  authentication log.
  """
  @callback user_authentication_requested(socket()) :: :ok

  @doc """
  After the User authentication been accepted by
  the server, we need to log their connection on
  our server.
  """
  @callback user_authentication_accepted(socket(), User.t()) :: :ok

  @doc """
  After the User authentication been rejected by
  the server, we need to log their failure.
  """
  @callback user_authentication_rejected(socket(), atom()) :: :ok
end
