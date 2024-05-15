defmodule Mix.Tasks.Exathena.Migrate do
  @moduledoc false
  use Mix.Task
  import Mix.Exathena

  @shortdoc "Runs the repository migrations"

  @impl true
  def run(args) do
    repos = Application.get_env(:exathena, :ecto_repos)

    for repo <- repos do
      args = ["-r", get_repo_name(repo)] ++ args

      Mix.Tasks.Ecto.Migrate.run(args)
    end

    Mix.Tasks.Exathena.Dump.run([])
  end
end
