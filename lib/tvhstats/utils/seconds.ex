defmodule TVHStats.Utils.Seconds do
  @one_minute 60
  @one_hour 3600

  def to_hh_mm(seconds) do
    h =
      seconds
      |> div(3600)
      |> pad_int()

    m =
      seconds
      |> rem(3600)
      |> div(60)
      |> pad_int()

    "#{h}:#{m}"
  end

  def to_hh_mm_ss(seconds) when seconds >= @one_hour do
    h = div(seconds, @one_hour)

    m =
      seconds
      |> rem(@one_hour)
      |> div(@one_minute)
      |> pad_int()

    s =
      seconds
      |> rem(@one_hour)
      |> rem(@one_minute)
      |> pad_int()

    "#{h}:#{m}:#{s}"
  end

  def to_hh_mm_ss(seconds) do
    m = div(seconds, @one_minute)

    s =
      seconds
      |> rem(@one_minute)
      |> pad_int()

    "#{m}:#{s}"
  end

  defp pad_int(int, padding \\ 2) do
    int
    |> Integer.to_string()
    |> String.pad_leading(padding, "0")
  end
end
