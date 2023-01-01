defmodule TVHStats.Subscriptions.Query do
  @moduledoc """
  Queries to filter Subscriptions
  """

  import Ecto.Query

  alias TVHStats.Subscriptions.Subscription
  alias TVHStats.Utils

  def get_all() do
    from(s in Subscription, order_by: [desc: :started_at])
  end

  def get_paginated(page, items \\ 20) do
    offset = (page - 1) * items

    from(
      s in Subscription,
      offset: ^offset,
      limit: ^items,
      order_by: [desc: :started_at]
    )
  end

  def get_count() do
    from(s in Subscription, select: count(s.hash))
  end

  def list_by_hash(hash_list) do
    from(s in Subscription, where: s.hash in ^hash_list)
  end

  def get_by_hash(hash) do
    from(s in Subscription, where: s.hash == ^hash)
  end

  def get_playing() do
    from(s in Subscription, where: is_nil(s.stopped_at))
  end

  def stop_all(hashes) do
    now = DateTime.utc_now()

    from(
      s in Subscription,
      where: s.hash in ^hashes,
      update: [set: [stopped_at: ^now, updated_at: ^now]]
    )
  end

  def get_play_count(field, last_n_days) do
    date = Utils.datetime_n_days_ago(last_n_days)

    from(
      s in Subscription,
      select: %{"plays" => count(s.hash)},
      where: s.started_at > ^date and not is_nil(s.stopped_at),
      group_by: ^field,
      order_by: [desc: count(s.hash)],
      limit: 5
    )
    |> add_field(field)
  end

  def get_play_duration(field, last_n_days) do
    date = Utils.datetime_n_days_ago(last_n_days)

    from(
      s in Subscription,
      select: %{
        "duration" => sum(fragment("EXTRACT(EPOCH FROM(? - ?))", s.stopped_at, s.started_at))
      },
      where: s.started_at > ^date and not is_nil(s.stopped_at),
      group_by: ^field,
      order_by: [desc: sum(s.stopped_at - s.started_at)],
      limit: 5
    )
    |> add_field(field)
  end

  def get_play_activity(last_n_days) do
    date = Utils.datetime_n_days_ago(last_n_days)

    from(
      s in Subscription,
      select: %{"channel" => s.channel, "users" => count(s.user)},
      where: s.started_at > ^date and not is_nil(s.stopped_at),
      group_by: s.channel,
      order_by: [desc: count(s.user)],
      limit: 5
    )
  end

  @doc "to_char function for formatting datetime as dd MON YYYY"
  defmacro to_char(field, format) do
    quote do
      fragment("to_char(?, ?)", unquote(field), unquote(format))
    end
  end

  def get_daily_activity(last_n_days) do
    date = Utils.datetime_n_days_ago(last_n_days)

    from(
      s in Subscription,
      select: {to_char(s.started_at, "dd Mon YYYY"), count(s.hash)},
      where: s.started_at > ^date,
      group_by: to_char(s.started_at, "dd Mon YYYY")
    )
  end

  defp add_field(q, :user) do
    select_merge(q, [s], %{"user" => s.user})
  end

  defp add_field(q, :channel) do
    select_merge(q, [s], %{"channel" => s.channel})
  end
end
