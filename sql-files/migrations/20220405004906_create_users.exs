defmodule ExAthena.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :username, :string, null: false
      add :email, :binary, null: false
      add :web_auth_token, :binary
      add :password, :string, null: false
      add :account_type, :string, default: "player"
      add :role, :string, default: "player"
      add :sex, :string, default: "masculine"
      add :birth_at, :date
      add :session_count, :integer
      add :character_slots, :integer
      add :web_auth_token_enabled, :boolean, default: false, null: false

      add :encrypted_email, :binary, null: false
      add :encrypted_web_auth_token, :binary

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:encrypted_email])

    execute "ALTER SEQUENCE users_id_seq RESTART WITH 2000000;"
  end

  def down do
    drop table(:users)
  end
end
