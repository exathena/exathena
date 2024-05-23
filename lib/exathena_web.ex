defmodule ExAthenaWeb do
  @moduledoc false

  def static_paths, do: ~w(assets fonts images robots.txt)

  def socket do
    quote do
      use Phoenix.Socket
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      unquote(verified_routes())
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: ExAthenaWeb.Layouts]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ExAthenaWeb.Endpoint,
        router: ExAthenaWeb.Router,
        statics: ExAthenaWeb.static_paths()

      import Phoenix.VerifiedRoutes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
