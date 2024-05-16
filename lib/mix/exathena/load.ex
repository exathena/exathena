defmodule Mix.Tasks.Exathena.Load do
  @moduledoc false
  use Mix.Task
  import Mix.Exathena

  @shortdoc "Loads previously dumped database structure"

  @impl true
  def run(args) do
    repos = Application.get_env(:exathena, :ecto_repos)

    for repo <- repos do
      args = ["-r", get_repo_name(repo), "-d", get_sql_folder(repo)] ++ args

      Mix.Tasks.Ecto.Load.run(args)
    end
  end
end
