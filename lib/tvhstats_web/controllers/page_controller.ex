defmodule TVHStatsWeb.PageController do
  use TVHStatsWeb, :controller

  alias TVHStats.Utils

  @history_params_schema %{
    page: [type: :integer, default: 1, number: [min: 1]],
    size: [type: :integer, default: 20, in: [3, 20, 50, 100]]
  }

  def history(conn, params) do
    with {:ok, %{page: page, size: size}} <- Tarams.cast(params, @history_params_schema) do
      timezone = Application.get_env(:tvhstats, :tvh_tz)

      subscriptions =
        Enum.map(TVHStats.Subscriptions.list(page, size), &parse_subscription(&1, timezone))

      subscription_count = TVHStats.Subscriptions.count()

      conn
      |> assign(:page_title, "History")
      |> assign(:subscriptions, subscriptions)
      |> assign(:page, page)
      |> assign(:page_size, size)
      |> assign(:next_page, page + 1)
      |> assign(:prev_page, page - 1)
      |> assign(:show_next_page, show_next_page?(page + 1, subscription_count, size))
      |> assign(:total_items, subscription_count)
      |> render("history.html")
    else
      {:error, errors} ->
        Plug.Conn.send_resp(conn, 400, Jason.encode!(errors))
    end
  end

  def get_graphs(conn, _params) do

    conn
    |> assign(:page_title, "Graphs")
    |> assign(:daily_play_count, get_daily_play_count())
    |> assign(:hourly_play_count, get_hourly_play_count())
    |> assign(:weekday_play_count, get_weekday_play_count())
    |> render("graphs.html")
  end

  defp show_next_page?(next_page, total_items, page_size) do
    next_page <= Float.ceil(total_items / page_size)
  end

  defp parse_subscription(subscription, timezone) do
    shifted_started_at = DateTime.shift_zone!(subscription.started_at, timezone)

    %{
      start_date: Calendar.strftime(shifted_started_at, "%Y-%m-%d"),
      start_time: Calendar.strftime(shifted_started_at, "%H:%M"),
      stop_time:
        if(subscription.stopped_at,
          do:
            subscription.stopped_at
            |> DateTime.shift_zone!(timezone)
            |> Calendar.strftime("%H:%M"),
          else: nil
        ),
      channel: subscription.channel,
      user: subscription.user,
      ip: subscription.ip,
      duration:
        DateTime.diff(
          if(subscription.stopped_at, do: subscription.stopped_at, else: DateTime.utc_now()),
          subscription.started_at,
          :minute
        )
    }
  end

  defp get_daily_play_count() do
    plays =
      30
      |> TVHStats.Subscriptions.get_daily_plays()
      |> Enum.into(%{})

    0..29
    |> Stream.map(&Utils.datetime_n_days_ago/1)
    |> Stream.map(fn date -> {date, Calendar.strftime(date, "%d %b %Y")} end)
    |> Stream.map(fn
      {date, date_str} ->
        %{date: date, label: Calendar.strftime(date, "%b %d"), value: Map.get(plays, date_str, 0)}
    end)
    |> Enum.sort_by(&Map.get(&1, :date), {:asc, Date})
  end

  defp get_hourly_play_count() do
    plays =
      30
      |> TVHStats.Subscriptions.get_hourly_plays()
      |> Enum.map(fn {hour, value}-> {trunc(hour), value} end)
      |> Enum.into(%{})

    Enum.map(0..23, fn hour -> %{label: String.pad_leading("#{hour}", 2, "0"), value: Map.get(plays, hour, 0)} end)
  end

  defp get_weekday_play_count() do
    plays =
      30
      |> TVHStats.Subscriptions.get_weekday_plays()
      |> Enum.map(fn {hour, value}-> {trunc(hour), value} end)
      |> Enum.into(%{})

    Enum.map(1..7, fn weekday -> %{label: get_dow(weekday), value: Map.get(plays, weekday, 0)} end)
  end

  defp get_dow(1), do: "Monday"
  defp get_dow(2), do: "Tuesday"
  defp get_dow(3), do: "Wednesday"
  defp get_dow(4), do: "Thursday"
  defp get_dow(5), do: "Friday"
  defp get_dow(6), do: "Saturday"
  defp get_dow(7), do: "Sunday"
end
