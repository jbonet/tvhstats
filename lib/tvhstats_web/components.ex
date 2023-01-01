defmodule TVHStats.Components do
  use TVHStatsWeb, :view

  alias TVHStats.Utils.Seconds

  def stats_card(assigns) do
    [mode, stat] =
      assigns
      |> Map.get(:type)
      |> String.split("_")

    assigns =
      assigns
      |> Map.put(:mode, mode)
      |> Map.put(:stat, stat)

    render("stats_card.html", assigns)
  end

  def get_stat("count"), do: "plays"
  def get_stat("activity"), do: "users"
  def get_stat("duration"), do: "hh:mm"

  def parse_duration(seconds) do
    Seconds.to_hh_mm(seconds)
  end

  def encode_uri(channel) do
    :uri_string.quote(channel)
  end

  def get_icon([]), do: ""

  def get_icon([head | _]) do
    channel =
      head
      |> Map.get("channel")
      |> encode_uri()

    "/icons/#{channel}.png"
  end

  def get_user_initial([]), do: ""

  def get_user_initial([head | _]) do
    head
    |> Map.get("user")
    |> String.first()
  end

  def get_channel(%{channel: channel}), do: channel
  def get_channel(_), do: "N/A"
end
