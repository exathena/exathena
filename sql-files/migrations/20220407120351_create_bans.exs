defmodule ExAthena.Repo.Migrations.CreateBans do
  use Ecto.Migration

  def up do
    create table(:bans) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :banned_until, :utc_datetime, null: false

      timestamps(updated_at: false)
    end

    create index(:bans, [:user_id])
  end

  def down do
    drop table(:bans)
  end
end
