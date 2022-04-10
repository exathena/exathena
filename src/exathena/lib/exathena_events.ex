defmodule ExAthenaEvents do
  @moduledoc """
  The ExAthena event producer.

  It dispatch events to their recipient or
  enqueues it to Oban to be performed as a
  background job.
  """

  alias ExAthena.Accounts.User

  @client Application.compile_env(:exathena, :events_module, ExAthenaEvents.Producer)

  @doc """
  After an User request authentication, this
  event is dispatched to generate an
  authentication log.

  ## Examples

      iex> user_authentication_requested(#PID<0.110.0>)
      :ok

  """
  @spec user_authentication_requested(port()) :: :ok
  def user_authentication_requested(socket) when is_port(socket) do
    @client.user_authentication_requested(socket)
  end

  @doc """
  After the User authentication been accepted by
  the server, we need to log their connection on
  our server.

  ## Examples

      iex> user_authentication_accepted(#PID<0.110.0>, %User{})
      :ok

  """
  @spec user_authentication_accepted(port(), User.t()) :: :ok
  def user_authentication_accepted(socket, user = %User{}) when is_port(socket) do
    @client.user_authentication_accepted(socket, user)
  end

  @doc """
  After the User authentication been rejected by
  the server, we need to log their failure.

  ## Examples

      iex> user_authentication_rejected(#PID<0.110.0>, :invalid_credentials)
      :ok

  """
  @spec user_authentication_rejected(port(), atom()) :: :ok
  def user_authentication_rejected(socket, result) when is_port(socket) and is_atom(result) do
    @client.user_authentication_rejected(socket, result)
  end
end
