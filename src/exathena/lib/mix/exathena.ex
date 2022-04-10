defmodule Mix.Exathena do
  @moduledoc false

  @doc false
  def get_sql_folder(ExAthena.Repo), do: "sql-files/main.sql"
  def get_sql_folder(ExAthenaLogger.Repo), do: "sql-files/logs.sql"

  @doc false
  def get_repo_name(repo) do
    "Elixir." <> module = to_string(repo)
    module
  end
end
