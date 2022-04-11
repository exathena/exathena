defmodule ExAthena.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ExAthenaLogger.Sql

  @impl true
  def start(_type, _args) do
    env = Mix.env()

    children =
      [
        ExAthena.Repo,
        ExAthenaWeb.Telemetry,
        {Phoenix.PubSub, name: ExAthena.PubSub},
        ExAthenaWeb.Endpoint,
        ExAthena.Vault,
        {Registry, keys: :unique, name: ExAthena.Config.Registry}
      ] ++
        oban(env) ++
        logger_repo(env) ++
        start_configs(env)

    :ok = start_handlers(env)

    opts = [strategy: :one_for_one, name: ExAthena.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban(:test), do: []

  defp oban(_) do
    config = Application.get_env(:exathena, Oban)
    [{Oban, config}]
  end

  defp logger_repo(:test), do: [ExAthenaLogger.Repo]

  defp logger_repo(_) do
    case Application.get_env(:exathena, :logger_adapter) do
      Sql -> [ExAthenaLogger.Repo]
      _ -> []
    end
  end

  defp start_handlers(:test), do: :ok

  defp start_handlers(_) do
    :ok = start_handlers(:test)
    :ok = ExAthenaLogger.start_handlers()
  end

  defp start_configs(:test), do: []

  defp start_configs(_) do
    ExAthena.Config.start_configs()
  end

  @impl true
  def config_change(changed, _new, removed) do
    ExAthenaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
