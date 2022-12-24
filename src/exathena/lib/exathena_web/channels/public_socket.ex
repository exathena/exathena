defmodule ExAthenaWeb.PublicSocket do
  @moduledoc false
  use ExAthenaWeb, :socket

  channel "login", ExAthenaWeb.LoginChannel

  @impl true
  def connect(params, socket, connect_info) do
    {:ok, assign(socket, ip: fetch_ip(connect_info), params: params)}
  end

  defp fetch_ip(%{x_headers: x_headers}) do
    if ip_address = RemoteIp.from(x_headers) do
      ip_address |> :inet.ntoa() |> to_string()
    end
  end

  @impl true
  def id(socket) when socket.assigns.ip not in [nil, ""] do
    "public:#{socket.assigns.ip}"
  end
end
