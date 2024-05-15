defmodule ExAthenaLogger.Repo do
  use Ecto.Repo,
    otp_app: :exathena,
    adapter: Ecto.Adapters.Postgres
end
