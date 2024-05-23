defmodule ExAthenaWeb.LoginChannelJSON do
  def render(:not_found, _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render(:invalid_credentials, _assigns) do
    %{errors: %{detail: "Invalid Credentials"}}
  end

  def render(:unauthorized, _assigns) do
    %{errors: %{detail: "Unauthorized"}}
  end

  def render(:access_expired, _assigns) do
    %{errors: %{detail: "Your access expired"}}
  end

  def render(:user_denied, _assigns) do
    %{errors: %{detail: "User's IP is denylisted"}}
  end

  def render(:user_banned, banned_until: banned_until) do
    %{errors: %{detail: "Your account is banned until #{banned_until}"}}
  end

  def render(:internal_server_error, _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end
end
