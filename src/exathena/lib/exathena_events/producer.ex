defmodule ExAthenaEvents.Producer do
  @moduledoc """
  The ExAthena events producer.

  It produces an event to be dispatched
  by the event recipient, that could be
  a Oban worker, a telemetry event, etc.
  """
  @behaviour ExAthenaEvents.Behaviour

  alias ExAthena.Accounts.User

  @authentication_log_event [:exathena, :authentication, :log]

  @impl true
  def user_authentication_requested(socket) when is_port(socket) do
    :telemetry.execute(@authentication_log_event, %{}, %{socket: socket, type: :request})
  end

  @impl true
  def user_authentication_accepted(socket, user = %User{}) when is_port(socket) do
    :telemetry.execute(@authentication_log_event, %{}, %{
      socket: socket,
      user: user,
      result: :accepted
    })
  end

  @impl true
  def user_authentication_rejected(socket, result) when is_port(socket) and is_atom(result) do
    :telemetry.execute(@authentication_log_event, %{}, %{socket: socket, result: result})
  end
end
