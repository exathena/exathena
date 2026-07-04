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
      plt_add_apps: [:ecto, :phoenix, :mix, :ex_unit],
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
      # Phoenix Framework
      {:phoenix, "~> 1.7.12"},
      {:phoenix_ecto, "~> 4.6.1"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:plug_cowboy, "~> 2.7.1"},

      # Database
      {:ecto_sql, "~> 3.11.2"},
      {:postgrex, ">= 0.0.0"},

      # Encryption
      {:cloak_ecto, "~> 1.2.0"},
      {:pbkdf2_elixir, "~> 2.2.0"},

      # Background jobs
      {:oban, "~> 2.17.10"},

      # Mailing
      {:swoosh, "~> 1.16.7"},

      # Telemetry
      {:telemetry_metrics, "~> 1.0.0"},
      {:telemetry_poller, "~> 1.1.0"},

      # Peer data
      {:remote_ip, "~> 1.1.0"},

      # Internationalization
      {:gettext, "~> 0.24.0"},
      {:timex, "~> 3.7.11"},

      # File types
      {:jason, "~> 1.4.1"},
      {:yaml_elixir, "~> 2.9.0"},

      # Code quality & Security
      {:credo, "~> 1.7.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13.0", only: [:dev, :test], runtime: false},

      # Docs
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},

      # Test
      {:temporary_env, "~> 2.0.1", only: :test},
      {:mox, "~> 1.2.0", only: [:dev, :test]},
      {:assertions, "~> 0.19.0", only: :test},
      {:bypass, "~> 2.1.0", only: :test},
      {:ex_machina, "~> 2.7.0", only: [:dev, :test]},
      {:faker, "~> 0.18.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.18.1", only: :test, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "exathena.load", "run sql-files/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.migrate": ["ecto.migrate", "ecto.dump"],
      "ecto.rollback": ["ecto.rollback", "ecto.dump"],
      sobelow: ["sobelow"],
      test: ["ecto.drop -q", "ecto.create -q", "exathena.load -q", "test"]
    ]
  end
end
