defmodule TVHStatsWeb.LayoutView do
  use TVHStatsWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def nav_link(conn, text, opts) do
    to = opts[:to]

    case Map.fetch(conn, :request_path) do
      {:ok, ^to} ->
        classes = opts[:class]

        link(
          text,
          opts
          |> Keyword.delete(:class)
          |> Kernel.++(class: "#{classes} text-blue-700 hover:text-blue-500")
        )

      _ ->
        classes = opts[:class]

        link(
          text,
          opts
          |> Keyword.delete(:class)
          |> Kernel.++(class: "#{classes} text-gray-400 hover:text-white")
        )
    end
  end
end
