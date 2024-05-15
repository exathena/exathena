defmodule Mix.Tasks.Exathena.Dump do
  @moduledoc false
  use Mix.Task
  import Mix.Exathena

  @shortdoc "Dumps the repository database structure"

  @impl true
  def run(args) do
    repos = Application.get_env(:exathena, :ecto_repos)

    for repo <- repos do
      sql_folder = get_sql_folder(repo)
      args = ["-r", get_repo_name(repo), "-d", sql_folder] ++ args

      Mix.Tasks.Ecto.Dump.run(args)
    end
  end
end
