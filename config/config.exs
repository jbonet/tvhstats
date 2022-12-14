# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tvhstats,
  ecto_repos: [TVHStats.Repo]

config :tvhstats, TVHStats.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :tvhstats, TVHStatsWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 4000],
  render_errors: [view: TVHStatsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TVHStats.PubSub,
  live_view: [signing_salt: "sRL1PAld"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tvhstats, TVHStats.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=../priv/static/assets/app.css.tailwind
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# https://github.com/CargoSense/dart_sass
config :dart_sass,
  version: "1.55.0",
  default: [
    args: ~w(
      css/app.scss
      ../priv/static/assets/app.css.tailwind
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
