defmodule TVHStatsWeb.IconsController do
  use TVHStatsWeb, :controller

  def get_icon(conn, %{"path" => path}) do
    icons_folder = Application.get_env(:tvhstats, :icon_cache_dir)
    icon_path = "#{icons_folder}/#{path}"

    if File.exists?(icon_path) do
      send_download(conn, {:file, icon_path})
    else
      conn
      |> put_status(404)
      |> json(%{error: "Icon does not exist: " <> icon_path})
    end
  end
end