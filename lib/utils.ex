defmodule PoloniexWebsocket.Utils do
  def to_integer(num) do
    parts = String.split(num, ".") |> Enum.reverse

    [String.duplicate("0", 8-String.length(hd(parts))) | parts] |>
      Enum.reverse |>
      Enum.join |>
      Integer.parse |>
      elem(0)
  end
end
