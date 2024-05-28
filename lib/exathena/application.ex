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
        {Oban, oban}
      ] ++
        logger_repo() ++
        start_configs() ++
        start_databases()

    :ok = start_handlers()

    opts = [strategy: :one_for_one, name: ExAthena.Supervisor]
    Supervisor.start_link(children, opts)
  end

  cond do
    ExAthenaLogger.Sql in Application.compile_env(:exathena, :logger_adapters, []) ->
      defp logger_repo, do: [ExAthenaLogger.Repo]

    Mix.env() == :test ->
      defp logger_repo, do: [ExAthenaLogger.Repo]

    :else ->
      defp logger_repo, do: []
  end

  if Mix.env() == :test do
    defp start_handlers, do: :ok
  else
    defp start_handlers, do: ExAthenaLogger.start_handlers()
  end

  if Mix.env() == :test do
    defp start_configs, do: []
  else
    defp start_configs, do: [ExAthena.Config]
  end

  if Mix.env() == :test do
    defp start_databases, do: []
  else
    defp start_databases, do: [ExAthena.Database]
  end

  @impl true
  def config_change(changed, _new, removed) do
    ExAthenaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
