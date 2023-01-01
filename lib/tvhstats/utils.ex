defmodule TVHStats.Utils do
  @seconds_in_day 86400

  def datetime_n_days_ago(days) do
    DateTime.utc_now()
    |> DateTime.add(-1 * days * @seconds_in_day)
    |> at_midnight()
  end

  def at_midnight(datetime) do
    datetime
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00])
  end
end
