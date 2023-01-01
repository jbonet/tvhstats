defmodule TVHStats.Worker.Producer do
  @moduledoc """
  Produces data fetched from the TVHeadend API.
  """

  use GenStage

  require Logger

  alias TVHStats.API.Client

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(_) do
    poll_interval = Application.get_env(:tvhstats, :poll_interval)
    Logger.info("API polling worker started. Poll interval: #{poll_interval}")
    schedule_fetch(poll_interval)

    {:producer, %{poll_interval: poll_interval}, [dispatcher: GenStage.BroadcastDispatcher]}
  end

  def handle_demand(_, state), do: {:noreply, [], state}

  def handle_info(:fetch, %{poll_interval: poll_interval} = state) do
    schedule_fetch(poll_interval)
    GenStage.cast(self(), :fetch)

    {:noreply, [], state}
  end

  def handle_cast(:fetch, state) do
    streams = Client.get_streams()

    {:noreply, [streams], state}
  end

  defp schedule_fetch(poll_interval) do
    Process.send_after(self(), :fetch, poll_interval)
  end
end
