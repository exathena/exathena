defmodule Elixir.ExAthena.Repo.Migrations.CreateObanTables do
  use Ecto.Migration

  defdelegate up, to: Oban.Migrations
  defdelegate down, to: Oban.Migrations
end
