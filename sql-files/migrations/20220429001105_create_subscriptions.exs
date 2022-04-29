defmodule ExAthena.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def up do
    create table(:subscriptions) do
      add :user_id, references(:users), null: false
      add :until, :utc_datetime, null: false

      timestamps(updated_at: false)
    end

    create index(:subscriptions, [:user_id])
  end

  def down do
    drop table(:subscriptions)
  end
end
