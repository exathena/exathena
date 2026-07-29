defmodule ExAthena.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    oban = Application.get_env(:exathena, Oban)

    children =
      [
        ExAthena.Repo,
        ExAthenaWeb.Telemetry,
        {Phoenix.PubSub, name: ExAthena.PubSub},
        ExAthenaWeb.Endpoint,
        ExAthena.Vault,
        {Registry, keys: :unique, name: ExAthenaMmo.Registry},
        {DynamicSupervisor, strategy: :one_for_one, name: ExAthenaMmo.Client},
        {Oban, oban},
        ExAthena.Config,
        ExAthena.Database
      ]

    opts = [strategy: :one_for_one, name: ExAthena.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ExAthenaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
