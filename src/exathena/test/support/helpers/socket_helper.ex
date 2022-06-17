defmodule ExAthenaWeb.SocketHelper do
  @moduledoc false

  # The default endpoint for testing
  @endpoint ExAthenaWeb.Endpoint

  import Phoenix.ChannelTest

  @doc false
  @spec join_public_channel(module(), binary(), map()) :: Phoenix.Socket.t()
  def join_public_channel(channel, topic, opts \\ []) do
    socket_payload = opts[:socket_payload] || %{}
    channel_payload = opts[:channel_payload] || %{}

    connect_info = %{
      uri: URI.parse(ExAthenaWeb.Endpoint.url()),
      x_headers: [{"x-real-ip", "200.120.10.67"}]
    }

    with {:ok, socket} <- connect(ExAthenaWeb.PublicSocket, socket_payload, connect_info),
         {:ok, _params, socket} <- subscribe_and_join(socket, channel, topic, channel_payload) do
      socket
    end
  end
end
