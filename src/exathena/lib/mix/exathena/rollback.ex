defmodule Mix.Tasks.Exathena.Rollback do
  @moduledoc false
  use Mix.Task
  import Mix.Exathena

  @shortdoc "Rolls back the repository migrations"

  @impl true
  def run(args) do
    repos = Application.get_env(:exathena, :ecto_repos)

    for repo <- repos do
      args = ["-r", get_repo_name(repo)] ++ args

      Mix.Tasks.Ecto.Rollback.run(args)
    end

    Mix.Tasks.Exathena.Dump.run([])
  end
end
