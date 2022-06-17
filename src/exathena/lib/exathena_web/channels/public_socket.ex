defmodule ExAthenaWeb.PublicSocket do
  @moduledoc false
  use ExAthenaWeb, :socket

  channel "login", ExAthenaWeb.LoginChannel

  @impl true
  def connect(params, socket, connect_info) do
    ip_address = RemoteIp.from(connect_info[:x_headers])
    ip = ip_address |> :inet.ntoa() |> to_string()

    {:ok, assign(socket, ip: ip, params: params)}
  end

  @impl true
  def id(%Phoenix.Socket{assigns: %{ip: ip}}) when ip not in [nil, ""], do: "public:#{ip}"
  def id(_socket), do: "public:#{Ecto.UUID.generate()}"
end
