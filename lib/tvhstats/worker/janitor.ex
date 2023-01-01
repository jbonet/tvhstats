defmodule TVHStats.Worker.Janitor do
  @moduledoc """
  Clears stale records so there are no inconsistencies when starting up the app.
  """

  use Task

  require Logger

  def start_link(_args) do
    Task.start_link(__MODULE__, :cleanup_records, [])
  end

  def cleanup_records() do
    Logger.info("[Janitor] Cleaning up records task started.")

    stored_subscriptions =
      TVHStats.Subscriptions.currently_playing()
      |> Enum.map(& &1.hash)
      |> MapSet.new()

    %{"entries" => current_streams} = TVHStats.API.Client.get_streams()

    current_streams =
      current_streams
      |> Enum.map(&Map.get(&1, "hash"))
      |> MapSet.new()

    stale_subscriptions =
      stored_subscriptions
      |> MapSet.difference(current_streams)
      |> MapSet.to_list()

    TVHStats.Subscriptions.remove_all_by_hash(stale_subscriptions)
  end

  def remove_surfing_records(subscriptions) do
    Logger.info("[Janitor] Removing surfing records.")

    TVHStats.Subscriptions.remove_all_by_hash(subscriptions)
  end
end
