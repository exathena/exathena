defmodule ExAthenaLogger.Repo.Migrations.CreateAuthenticationLogs do
  use Ecto.Migration

  def up do
    create table(:authentication_logs) do
      add :user_id, :integer
      add :message, :text, null: false
      add :metadata, :json, null: false

      timestamps(updated_at: false)
    end
  end

  def down do
    drop table(:authentication_logs)
  end
end
