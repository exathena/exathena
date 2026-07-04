import Config

# Configures the application
config :exathena,
  namespace: ExAthena,
  ecto_repos: [ExAthena.Repo]

# Configures the endpoint
config :exathena, ExAthenaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+fj/WbccwC8b3rS6rK2NPVcfM4xMZLQ24duQAqY0o2gXnfUdj28C0LE65ivCQSw4",
  render_errors: [view: ExAthenaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ExAthena.PubSub,
  live_view: [signing_salt: "oLv1XUQM"]

# Configures the repos
config :exathena, ExAthena.Repo, priv: "sql-files"

# Configures the translation (getttext)
config :exathena, ExAthenaWeb.Gettext,
  default_locale: "en_US",
  priv: "translations"

# Configures Cloak for data encryption
config :exathena, ExAthena.Vault,
  ciphers: [
    default: {
      Cloak.Ciphers.AES.GCM,
      tag: "AES.GCM.V1",
      key: Base.decode64!("fJDguvHGwGICpJJt12/sw6CD2qnC2EZ38j5kAKIMCzI="),
      iv_length: 12
    }
  ]

# Configure Oban, the jobs processing lib
config :exathena, Oban,
  repo: ExAthena.Repo,
  plugins: [{Oban.Plugins.Pruner, limit: 10_000, max_age: 60 * 60 * 24 * 21}],
  queues: [default: 10]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :exathena, ExAthena.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console, metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
