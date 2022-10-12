defmodule TVHStats.Utils do
  def at_midnight(datetime) do
    datetime
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00])
  end
end
