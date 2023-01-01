defmodule TVHStats.Worker.CacheWarmer do
  use Task

  require Logger

  def start_link(_args) do
    Task.start_link(__MODULE__, :retrieve_icons, [])
  end

  def retrieve_icons() do
    Logger.info("[CacheWarmer] Task Retrieve icons started.")
    icons_folder = Application.get_env(:tvhstats, :icon_cache_dir)

    unless File.exists?(icons_folder) do
      Logger.info("[CacheWarmer] Icons folder does not exist, creating it.")
      File.mkdir(icons_folder)
    end

    Logger.info("[CacheWarmer] Saving icons to: #{icons_folder}")

    TVHStats.API.Client.get_channels()
    |> Enum.map(&Map.take(&1, ["icon", "name"]))
    |> Enum.map(&Task.async(fn -> store_in_cache(&1, icons_folder) end))
    |> Enum.map(&Task.await/1)

    Logger.info("[CacheWarmer] Finished warming up icons.")
  end

  defp store_in_cache(%{"icon" => "http" <> _ = icon, "name" => channel}, icons_folder) do
    req = Finch.build(:get, icon)

    file_ext =
      icon
      |> String.split(".")
      |> List.last()

    file_path = "#{icons_folder}/#{channel}.#{file_ext}"

    unless File.exists?(file_path) do
      Logger.debug(
        "[CacheWarmer] Icon for [#{channel}] does not exist, lets fetch it. [#{file_path}]"
      )

      with {:ok, %Finch.Response{body: response, status: 200}} <- Finch.request(req, HttpClient) do
        File.write(file_path, response)
      else
        _ ->
          Logger.error("[CacheWarmer] Could not get icon for: #{channel}")
      end
    end
  end

  defp store_in_cache(%{"icon" => "picon" <> _, "name" => channel}, _) do
    Logger.warning(
      "[CacheWarmer] Icon for channel #{channel} can not be downloaded. Picon protocol not supported yet."
    )
  end

  defp store_in_cache(%{"icon" => icon, "name" => channel}, _) do
    Logger.warning(
      "[CacheWarmer] Icon for channel #{channel} can not be downloaded. Unknown format for link: #{icon}"
    )
  end
end
