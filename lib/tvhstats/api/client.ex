defmodule TVHStats.API.Client do
  @moduledoc """
  Module used to interface with Tvheadend API
  """

  require Logger

  alias TVHStats.Subscriptions.Utils, as: SubscriptionUtils

  @page_size 100

  def get_streams() do
    req = build_request("/status/subscriptions")

    {:ok, %Finch.Response{body: response, status: 200}} = Finch.request(req, HttpClient)

    %{"entries" => subscriptions, "totalCount" => count} = Jason.decode!(response)

    %{
      "entries" =>
        subscriptions
        |> Enum.map(&parse_subscription(&1))
        |> Enum.sort_by(& &1["start"]),
      "totalCount" => count
    }
  end

  def get_channels(channels \\ [], page \\ 0, processed \\ 0) do
    req = build_request("/channel/grid", %{start: page * @page_size, limit: @page_size})

    {:ok, %Finch.Response{body: response, status: 200}} = Finch.request(req, HttpClient)

    %{"entries" => recv_channels, "total" => _total} = Jason.decode!(response)

    if length(recv_channels) > 0 do
      get_channels(channels ++ recv_channels, page + 1, processed + length(channels))
    else
      channels
    end
  end

  defp parse_subscription(subscription) do
    hash = SubscriptionUtils.generate_hash(subscription)

    stream_type =
      subscription
      |> Map.get("title")
      |> String.downcase()

    subscription
    |> Map.put("hash", hash)
    |> Map.put("stream_type", stream_type)
  end

  defp build_request(endpoint, query_params \\ nil) do
    Finch.build(:get, "#{url()}#{endpoint}#{params(query_params)}", headers())
  end

  defp url() do
    host = Application.get_env(:tvhstats, :tvh_host)
    port = Application.get_env(:tvhstats, :tvh_port)
    schema = if Application.get_env(:tvhstats, :tvh_use_https), do: "https", else: "http"

    "#{schema}://#{host}:#{port}/api"
  end

  defp headers() do
    user = Application.get_env(:tvhstats, :tvh_user)
    password = Application.get_env(:tvhstats, :tvh_password)

    [{"Authorization", "Basic #{Base.encode64("#{user}:#{password}")}"}]
  end

  defp params(nil), do: ""

  defp params(query_params) do
    encoded_query_params =
      query_params
      |> UriQuery.params()
      |> URI.encode_query()

    "?#{encoded_query_params}"
  end
end
