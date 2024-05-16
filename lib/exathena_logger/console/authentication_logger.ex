defmodule ExAthenaLogger.Console.AuthenticationLogger do
  @moduledoc """
  The ExAthena Logger handler for authentication events.
  """
  @behaviour ExAthenaLogger.Console

  @impl true
  def get_log_message(%{socket: %Phoenix.Socket{assigns: %{ip: ip}}, type: :request}) do
    "Received request authentication from ip #{ip}"
  end

  def get_log_message(%{socket: %Phoenix.Socket{assigns: %{ip: ip}}, result: :invalid_credentials}) do
    "Connection refused from ip #{ip} due to invalid credentials"
  end

  def get_log_message(%{socket: %Phoenix.Socket{assigns: %{ip: ip}}, result: :not_found}) do
    "Connection refused from ip #{ip} due to not found the given username"
  end

  def get_log_message(%{socket: %Phoenix.Socket{assigns: %{ip: ip}}, result: :access_expired}) do
    "Connection refused from ip #{ip} due to access expired"
  end

  def get_log_message(%{
        socket: %Phoenix.Socket{id: id, assigns: %{ip: ip}},
        user: user,
        banned_until: banned_until,
        result: :user_banned
      }) do
    "Connection refused from user #{user.id} ip #{ip} with id #{id} due to user being banned until #{banned_until}"
  end

  def get_log_message(%{
        socket: %Phoenix.Socket{assigns: %{ip: ip}},
        user: user,
        result: :accepted
      }) do
    "Connection accepted from ip #{ip} associated to user #{user.id}"
  end

  @impl true
  def build_metadata(measurements, %{
        user: user,
        socket: %Phoenix.Socket{id: id, assigns: %{ip: ip}, join_ref: join_ref},
        banned_until: banned_until
      }) do
    Map.merge(measurements, %{
      socket_id: id,
      user_id: user.id,
      banned_until: banned_until,
      join_ref: join_ref,
      ip: ip
    })
  end

  def build_metadata(measurements, %{
        user: user,
        socket: %Phoenix.Socket{id: id, assigns: %{ip: ip}, join_ref: join_ref}
      }) do
    Map.merge(measurements, %{socket_id: id, user_id: user.id, join_ref: join_ref, ip: ip})
  end

  def build_metadata(measurements, %{
        socket: %Phoenix.Socket{id: id, assigns: %{ip: ip}, join_ref: join_ref}
      }) do
    Map.merge(measurements, %{socket_id: id, join_ref: join_ref, ip: ip})
  end

  @impl true
  def get_log_type(%{type: :request}), do: :debug
  def get_log_type(%{result: :accepted}), do: :info
  def get_log_type(%{result: :user_banned}), do: :error
  def get_log_type(%{result: _}), do: :warning
end
