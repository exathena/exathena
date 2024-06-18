import Config

# Configures the application
config :exathena,
  settings_path: Path.expand(""),
  database_path: Path.expand(""),
  events_module: ExAthenaEventsMock,
  clock_module: ExAthena.ClockMock,
  logger_adapter: ExAthenaLoggerMock

# Configure your databases
config :exathena, ExAthena.Repo,
  username: "postgres",
  password: "postgres",
  database: "exathena_test",
  hostname: "localhost",
  log: false,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :exathena, ExAthenaLogger.Repo,
  username: "postgres",
  password: "postgres",
  database: "exathena_logger_test",
  hostname: "localhost",
  log: false,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exathena, ExAthenaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false

# In test we don't send emails.
config :exathena, ExAthena.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, :console, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configures Pbkdf2
config :pbkdf2_elixir, rounds: 1

# Don't run Oban jobs on tests automatically
config :exathena, Oban, testing: :manual

# Configures the application
config :exathena,
  database_path: "test/support",
  settings_path: "test/support"
