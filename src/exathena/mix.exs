defmodule ExAthena.MixProject do
  use Mix.Project

  def project do
    [
      app: :exathena,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {ExAthena.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib", "test/support/factories", "test/support/factory.ex"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:assertions, "~> 0.10", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:cloak_ecto, "~> 1.2"},
      {:ecto_sql, "~> 3.6"},
      {:ex_machina, "~> 2.7", only: [:dev, :test]},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:mox, "~> 1.0.0", only: :test},
      {:oban, "~> 2.11"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:phoenix, "~> 1.6.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:sobelow, "~> 0.11", only: :dev, runtime: false},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:temporary_env, "~> 2.0"},
      {:timex, "~> 3.7"},
      {:yaml_elixir, "~> 2.8"}
    ]
  end

  defp aliases do
    [format: "cmd mix format"]
  end
end
