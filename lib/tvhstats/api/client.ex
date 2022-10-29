defmodule TVHStats.API.Client do
  @moduledoc """
  Module used to interface with Tvheadend API
  """

  require Logger

  alias TVHStats.Subscriptions.Utils, as: SubscriptionUtils

  @invalid_clients ["epggrab", "scan"]
  @page_size 100

  def get_streams() do
    res =
      "/status/subscriptions"
      |> build_request()
      |> send_request()

    case res do
      {:ok, response} ->
        %{"entries" => subscriptions, "totalCount" => _count} = response

        subscriptions =
          subscriptions
          |> Enum.map(&parse_subscription(&1))
          |> Enum.reject(&is_nil/1)
          |> Enum.sort_by(& &1["start"])

        %{
          "entries" => subscriptions,
          "totalCount" => length(subscriptions)
        }

      {:error, _reason} ->
        %{"entries" => [], "totalCount" => 0}
    end
  end

  def get_channels(channels \\ [], page \\ 0, processed \\ 0) do
    res =
      "/channel/grid"
      |> build_request(%{start: page * @page_size, limit: @page_size})
      |> send_request()

    case res do
      {:ok, response} ->
        %{"entries" => recv_channels, "total" => _total} = response

        if length(recv_channels) > 0 do
          get_channels(channels ++ recv_channels, page + 1, processed + length(channels))
        else
          channels
        end

      {:error, _reason} ->
        []
    end
  end

  defp parse_subscription(%{"title" => client}) when client in @invalid_clients, do: nil
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

  defp send_request(request) do
    case Finch.request(request, HttpClient) do
      {:ok, %Finch.Response{body: body, status: 200}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: 400}} ->
        Logger.error("Bad request. Malformed query.")
        {:error, :bad_request}

      {:ok, %Finch.Response{status: 401}} ->
        Logger.error("Request was not authorized. Please check your credentials.")
        {:error, :not_authenticated}

      {:ok, %Finch.Response{status: 500}} ->
        Logger.error("There was an error processing the request. Check your server for logs.")
        {:error, :server_error}

      {:ok, %Finch.Response{status: _status}} ->
        Logger.error("There was an unknown error processing the request.")
        {:error, :unknown_error}

      {:error, %Mint.TransportError{reason: reason}} ->
        Logger.error("There was an error sending the request: #{reason}. Please check you set your server correctly.")
        {:error, reason}
    end
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
