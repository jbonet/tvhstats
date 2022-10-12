defmodule TVHStats.Subscriptions.Utils do
  @moduledoc false

  @spec generate_hash(map) :: binary
  def generate_hash(%{"id" => id, "start" => start, "username" => user}) do
    :sha256
    |> :crypto.hash(:erlang.term_to_binary("#{id}_#{start}_#{user}"))
    |> Base.encode16()
  end
end
