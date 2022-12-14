import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

config :tvhstats,
  cache_icons: System.get_env("TVHSTATS_ICON_CACHE_ENABLED", "1") == "1",
  # TODO: Handle Picons at controller level, so the folder can be selected.
  icon_cache_dir: System.get_env("TVHSTATS_ICON_CACHE_FOLDER", "/app/icons"),
  poll_interval: "TVHSTATS_POLL_INTERVAL" |> System.get_env("1000") |> String.to_integer(),
  channel_surf_threshold:
    "TVHSTATS_CHANNEL_SURF_THRESHOLD" |> System.get_env("10000") |> String.to_integer(),
  tvh_host: System.get_env("TVHSTATS_TVHEADEND_HOST", "localhost"),
  tvh_port: "TVHSTATS_TVHEADEND_PORT" |> System.get_env("9981") |> String.to_integer(),
  tvh_user: System.get_env("TVHSTATS_TVHEADEND_USER"),
  tvh_password: System.get_env("TVHSTATS_TVHEADEND_PASSWORD"),
  tvh_use_https: System.get_env("TVHSTATS_TVHEADEND_USE_HTTPS", "0") == "1",
  tvh_tz: System.get_env("TVHSTATS_TIMEZONE", "Etc/UTC")

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/tvhstats start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :tvhstats, TVHStatsWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :tvhstats, TVHStats.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = 80

  allowed_origins =
    System.get_env("PHX_ALLOWED_HOSTS") ||
      raise """
      environment variable PHX_ALLOWED_HOSTS is missing.
      For example: localhost:8080
      """

  allowed_origins =
    allowed_origins
    |> String.split(",")
    |> Enum.map(&"//#{String.trim(&1)}")

  config :tvhstats, TVHStatsWeb.Endpoint,
    url: [host: host, port: port, scheme: "http"],
    check_origin: allowed_origins,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :tvhstats, TVHStats.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
