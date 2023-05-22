defmodule TVHStats.Worker.Consumer do
  @moduledoc """
  Processes the info obtained from the API.
  """

  use GenStage

  require Logger

  alias TVHStats.Subscriptions

  @initial_state []
  @subscriptions_topic "active_subs"

  def start_link(_args) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:consumer, @initial_state, subscribe_to: [TVHStats.Worker.Producer]}
  end

  def handle_events([subscriptions], _from, state) do
    new_state = process(subscriptions, state)

    Phoenix.PubSub.broadcast(
      TVHStats.PubSub,
      @subscriptions_topic,
      {"active_subscriptions", new_state}
    )

    {:noreply, [], new_state}
  end

  @spec process(map, list) :: list
  defp process(%{"entries" => _subscriptions, "totalCount" => 0}, []), do: []

  defp process(%{"entries" => _subscriptions, "totalCount" => 0}, state) do
    Logger.info("All subscriptions gone. Clear.")
    handle_stopped_subscriptions(state)
    @initial_state
  end

  defp process(%{"entries" => subscriptions, "totalCount" => _count}, state) do
    state_set =
      state
      |> Enum.map(&Map.get(&1, "hash"))
      |> MapSet.new()

    subscriptions_map =
      Enum.reduce(subscriptions, %{}, fn x, acc -> Map.put(acc, Map.get(x, "hash"), x) end)

    state_map = Enum.reduce(state, %{}, fn x, acc -> Map.put(acc, Map.get(x, "hash"), x) end)

    subscriptions_set =
      subscriptions
      |> Enum.map(&Map.get(&1, "hash"))
      |> MapSet.new()

    handle_started_subscriptions(
      subscriptions_set
      |> MapSet.difference(state_set)
      |> MapSet.to_list()
      |> Enum.map(&Map.get(subscriptions_map, &1))
    )

    handle_stopped_subscriptions(
      state_set
      |> MapSet.difference(subscriptions_set)
      |> MapSet.to_list()
      |> Enum.map(&Map.get(state_map, &1))
    )

    subscriptions
  end

  def handle_started_subscriptions(started_subscriptions) when started_subscriptions == [],
    do: :ok

  def handle_started_subscriptions(started_subscriptions) do
    started_subscriptions
    |> Enum.map(&transform(&1))
    |> Enum.each(&handle_started_subscription(&1))
  end

  defp handle_started_subscription(subscription) do
    Logger.debug("User #{subscription.user} started watching: #{subscription.channel}")

    Subscriptions.create(subscription)
  end

  def handle_stopped_subscriptions([]), do: :ok

  def handle_stopped_subscriptions(stopped_subscriptions) do
    now = DateTime.utc_now()

    transformed_stopped_subscriptions = Enum.map(stopped_subscriptions, &transform(&1))

    Enum.each(transformed_stopped_subscriptions, &handle_stopped_subscription(&1))

    to_stop =
      Enum.filter(transformed_stopped_subscriptions, &is_active_watching(&1[:started_at], now))

    Subscriptions.stop_all(to_stop)

    surfing_records =
      stopped_subscriptions
      |> Enum.map(& &1["hash"])
      |> MapSet.new()
      |> MapSet.difference(to_stop |> Enum.map(& &1[:hash]) |> MapSet.new())
      |> MapSet.to_list()

    Task.Supervisor.start_child(
      TVHStats.TaskSupervisor,
      TVHStats.Subscriptions,
      :remove_all_by_hash,
      [surfing_records]
    )
  end

  defp handle_stopped_subscription(subscription) do
    Logger.debug("User #{subscription[:user]} stopped watching: #{subscription[:channel]}")
  end

  defp transform(%{
         "hostname" => ip,
         "start" => start,
         "username" => user,
         "hash" => hash,
         "channel" => channel,
         "stream_type" => stream_type,
         "client" => client
        }) when stream_type in ["http", "htsp"] do
    %{
      hash: hash,
      user: user,
      channel: channel,
      ip: ip,
      started_at: DateTime.from_unix!(start),
      stream_type: stream_type,
      client: client
    }
  end
  
  defp transform(%{
     "hostname" => ip,
     "start" => start,
     "username" => user,
     "hash" => hash,
     "channel" => channel,
     "client" => client
   }) do
    %{
      hash: hash,
      user: user,
      channel: channel,
      ip: ip,
      started_at: DateTime.from_unix!(start),
      stream_type: "htsp",
      client: client
    }
  end

  defp transform(%{
         "hostname" => ip,
         "start" => start,
         "hash" => hash,
         "channel" => channel,
         "stream_type" => stream_type,
         "client" => client
       }) do
    %{
      hash: hash,
      user: "anonymous@" <> ip,
      channel: channel,
      ip: ip,
      started_at: DateTime.from_unix!(start),
      stream_type: stream_type,
      client: client
    }
  end

  def is_active_watching(start, now) do
    DateTime.diff(now, start, :millisecond) >
      Application.get_env(:tvhstats, :channel_surf_threshold)
  end
end
