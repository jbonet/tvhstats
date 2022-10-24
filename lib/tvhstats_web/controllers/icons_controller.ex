defmodule TVHStatsWeb.IconsController do
  use TVHStatsWeb, :controller

  def get_icon(conn, %{"path" => path}) do
    icons_folder = Application.get_env(:tvhstats, :icon_cache_dir)

    send_download(conn, {:file, "#{icons_folder}/#{path}"})
  end
end