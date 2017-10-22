defmodule PoloniexWebsocket.Messages.OrderBook do
  alias PoloniexWebsocket.Utils, as: Utils

  def from_market_data([raw_asks, raw_bids], nonce, timestamp) do
    %{
      type: :order_book,
      recorded_at: timestamp |> DateTime.to_string,
      nonce: nonce,
      bids: processed_raw_book_from(raw_bids),
      asks: processed_raw_book_from(raw_asks)
    }
  end

  defp processed_raw_book_from(data), do: data |> Enum.reduce(Map.new, &book_reductor/2)
  defp book_reductor({k, v}, acc), do: Map.put(acc, Utils.to_integer(k), Utils.to_integer(v))
end
