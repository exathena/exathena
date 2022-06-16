defmodule Elixir.ExAthenaLogger.Repo.Migrations.AlterAuthenticationLogsRenameSocketFdToJoinRef do
  use Ecto.Migration

  def up do
    drop index(:authentication_logs, [:socket_fd])
    rename table(:authentication_logs), :socket_fd, to: :join_ref
    create index(:authentication_logs, [:join_ref])
  end

  def down do
    drop index(:authentication_logs, [:join_ref])
    rename table(:authentication_logs), :join_ref, to: :socket_fd
    create index(:authentication_logs, [:socket_fd])
  end
end
