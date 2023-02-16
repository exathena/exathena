{:ok, _} = :application.ensure_all_started(:exathena)

# Start Faker
Faker.start()

# Start the tests
ExUnit.start(assert_receive_timeout: 1_500)

# Changes database mode to manual
Ecto.Adapters.SQL.Sandbox.mode(ExAthena.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(ExAthenaLogger.Repo, :manual)
