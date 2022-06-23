defmodule ExAthenaWeb.LoginChannel do
  @moduledoc false
  use ExAthenaWeb, :channel

  alias ExAthena.Accounts
  alias ExAthenaEvents
  alias ExAthenaWeb.Channel.LoginView

  @impl true
  def join("login", _params, socket) do
    if pid = socket.assigns.params["pid"] do
      send(pid, :login_join)
    end

    {:ok, socket}
  end

  @impl true
  def handle_in("authentication", credentials, socket) do
    %{"username" => username, "password" => password} = credentials

    if pid = socket.assigns.params["pid"] do
      send(pid, {:authentication, credentials})
    end

    ExAthenaEvents.user_authentication_requested(socket)

    with {:ok, user} <- Accounts.get_user_by_username(username),
         :ok <- Accounts.authenticate_user(user, password),
         :ok <- Accounts.authorize_user(user) do
      ExAthenaEvents.user_authentication_accepted(socket, user)
      push(socket, "authentication_accepted", %{})

      {:noreply, socket}
    else
      {:error, reason} ->
        error = render(LoginView, "#{reason}.json", %{})
        ExAthenaEvents.user_authentication_rejected(socket, reason)
        push(socket, "authentication_rejected", error)

        {:reply, {:error, error}, socket}

      {:error, :user_banned, banned_until} ->
        ExAthenaEvents.user_authentication_rejected(socket, :user_banned)
        error = render(LoginView, "user_banned.json", banned_until: banned_until)
        push(socket, "authentication_rejected", error)

        {:reply, {:error, error}, socket}
    end
  end
end
