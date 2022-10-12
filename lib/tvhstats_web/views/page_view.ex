defmodule TVHStatsWeb.PageView do
  use TVHStatsWeb, :view

  def get_last_item(page, size, total) when page * size > total, do: total
  def get_last_item(page, size, _total), do: page * size
end
