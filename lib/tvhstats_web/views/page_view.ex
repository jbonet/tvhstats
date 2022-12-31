defmodule TVHStatsWeb.PageView do
  use TVHStatsWeb, :view

  def get_last_item(page, size, total) when page * size > total, do: total
  def get_last_item(page, size, _total), do: page * size

  def fetch_chart_data(data) do
    Enum.map(data, fn {_date, value} -> value end)
  end
  def fetch_chart_labels(data) do
    Enum.map(data, fn {date, _value} -> date end)
  end
end
