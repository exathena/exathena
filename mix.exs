defmodule ExAthenaApp.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "src",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      gettext: gettext()
    ] ++ hex()
  end

  defp dialyzer do
    [
      plt_core_path: "tmp/plts",
      plt_file: {:no_warn, "tmp/dialyzer.plt"},
      plt_add_apps: [:ecto, :phoenix, :mix],
      ignore_warnings: ".dialyzerignore"
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
      name: "ExAthena",
      description: "exAthena is an open-source cross-platform MMORPG server.",
      package: [
        name: "exathena",
        maintainers: [~s(Alexandre "aleDsz" de Souza)],
        licenses: ["GNU General Public License v3.0"],
        links: %{"Github" => "https://github.com/ragnamoba/exathena"}
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.load", "run sql-files/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.load": ["ecto.load -d sql-files/main.sql --skip-if-loaded"],
      "ecto.dump": ["ecto.dump -d sql-files/main.sql"],
      "ecto.migrate": ["ecto.migrate", "ecto.dump"],
      "ecto.rollback": ["ecto.rollback", "ecto.dump"],
      sobelow: ["sobelow -r src/exathena"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.load --quiet", "test"]
    ]
  end
end
