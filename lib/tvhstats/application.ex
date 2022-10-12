defmodule TVHStats.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @pool_size Application.compile_env(:tvhstats, :conn_pool_size, 50)

  use Application

  @impl true
  def start(_type, _args) do
    services = [
      {Task.Supervisor, name: TVHStats.TaskSupervisor},
      {
        Finch,
        name: HttpClient,
        pools: %{
          :default => [size: @pool_size]
        }
      }
    ]

    phoenix_apps = [
      # Start the Telemetry supervisor
      TVHStatsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TVHStats.PubSub},
      # Start the Endpoint (http/https)
      TVHStatsWeb.Endpoint
    ]

    children = services ++ get_tasks() ++ phoenix_apps ++ get_workers()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TVHStats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TVHStatsWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def get_workers() do
    [
      {TVHStats.Worker.Producer, []},
      {TVHStats.Worker.Consumer, []}
    ]
  end

  def get_tasks() do
    cache_icons = Application.get_env(:tvhstats, :cache_icons)

    [
      # Start the Ecto repository
      TVHStats.Repo,
      # One off task: Clear stale records.
      {TVHStats.Worker.Janitor, []}
    ] ++ get_cache_warmer_worker(cache_icons)
  end

  def get_cache_warmer_worker(false), do: []
  def get_cache_warmer_worker(true), do: [{TVHStats.Worker.CacheWarmer, []}]
end
