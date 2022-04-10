defmodule ExAthenaLogger.Repo.Migrations.CreateAuthenticationLogs do
  use Ecto.Migration

  def up do
    create table(:authentication_logs) do
      add :user_id, :integer
      add :socket_fd, :integer, null: false
      add :ip, :binary, null: false
      add :encrypted_ip, :binary, null: false
      add :message, :text, null: false
      add :metadata, :json, null: false

      timestamps(updated_at: false)
    end

    create index(:authentication_logs, [:user_id])
    create index(:authentication_logs, [:socket_fd])
    create index(:authentication_logs, [:encrypted_ip])
  end

  def down do
    drop table(:authentication_logs)
  end
end
