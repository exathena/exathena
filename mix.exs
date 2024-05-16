defmodule ExAthena.MixProject do
  use Mix.Project

  def project do
    [
      app: :exathena,
      version: "0.1.0",
      config_path: "settings/config.exs",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        dialyzer: :dev,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      gettext: gettext()
    ] ++ hex()
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

  defp dialyzer do
    [
      plt_core_path: "tmp/plts",
      plt_file: {:no_warn, "tmp/dialyzer.plt"},
      plt_add_apps: [:ecto, :phoenix, :mix],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  defp gettext do
    [
      write_reference_comments: false,
      compiler_po_wildcard: "*/LC_MESSAGES/*.po"
    ]
  end

  defp hex do
    [
      name: "exAthena",
      description: "exAthena is an open-source cross-platform MMORPG server.",
      package: [
        name: "exathena",
        maintainers: [~s(Alexandre "aleDsz" de Souza)],
        licenses: ["GNU General Public License v3.0"],
        links: %{"Github" => "https://github.com/supaMOBA/exathena"}
      ]
    ]
  end

  defp deps do
    [
      {:cloak_ecto, "~> 1.2.0"},
      {:ecto_sql, "~> 3.10"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:oban, "~> 2.11"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:phoenix, "~> 1.7.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:remote_ip, "~> 1.0"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:temporary_env, "~> 2.0"},
      {:timex, "~> 3.7"},
      {:yaml_elixir, "~> 2.8"},

      # Dev
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, "~> 0.11", only: :dev, runtime: false},

      # Test
      {:mox, "~> 1.0.0", only: :test},
      {:assertions, "~> 0.10", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:ex_machina, "~> 2.7", only: [:dev, :test]},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:excoveralls, "~> 0.18.1", only: :test, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "exathena.load", "run sql-files/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      sobelow: ["sobelow"],
      test: ["ecto.drop -q", "ecto.create -q", "exathena.load -q", "test"]
    ]
  end
end
