defmodule ExAthena.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    env = Mix.env()

    children =
      [
        ExAthena.Repo,
        ExAthenaWeb.Telemetry,
        {Phoenix.PubSub, name: ExAthena.PubSub},
        ExAthenaWeb.Endpoint,
        ExAthena.Vault
      ] ++
        oban(env) ++
        logger_repo(env)


    opts = [strategy: :one_for_one, name: ExAthena.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban(:test), do: []

  defp oban(_) do
    config = Application.get_env(:exathena, Oban)
    [{Oban, config}]
  end

  defp logger_repo(:test), do: [ExAthenaLogger.Repo]
  defp logger_repo(_), do: []

  @impl true
  def config_change(changed, _new, removed) do
    ExAthenaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
