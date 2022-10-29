defmodule TVHStatsWeb.IconsController do
  use TVHStatsWeb, :controller

  def get_icon(conn, %{"path" => path}) do
    icons_folder = Application.get_env(:tvhstats, :icon_cache_dir)
    icon_path = "#{icons_folder}/#{path}"

    if File.exists?(icon_path) do
      send_download(conn, {:file, icon_path})
    else
      send_download(conn, {:file, Application.app_dir(:tvhstats, "priv") <> "/static/images/missing.png"})
    end
  end
end