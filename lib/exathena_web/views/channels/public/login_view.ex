defmodule ExAthenaWeb.Channel.LoginView do
  use ExAthenaWeb, :view

  def render("not_found.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("invalid_credentials.json", _assigns) do
    %{errors: %{detail: "Invalid Credentials"}}
  end

  def render("unauthorized.json", _assigns) do
    %{errors: %{detail: "Unauthorized"}}
  end

  def render("access_expired.json", _assigns) do
    %{errors: %{detail: "Your access expired"}}
  end

  def render("user_denied.json", _assigns) do
    %{errors: %{detail: "User's IP is denylisted"}}
  end

  def render("user_banned.json", %{banned_until: banned_until}) do
    %{errors: %{detail: "Your account is banned until #{banned_until}"}}
  end

  def render("internal_server_error.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end
end
