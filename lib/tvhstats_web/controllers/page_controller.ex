defmodule TVHStatsWeb.PageController do
  use TVHStatsWeb, :controller

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
end
