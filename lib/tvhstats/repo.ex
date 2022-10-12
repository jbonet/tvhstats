defmodule TVHStats.Repo do
  use Ecto.Repo,
    otp_app: :tvhstats,
    adapter: Ecto.Adapters.Postgres
end
