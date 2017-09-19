defmodule PoloniexWebsocket.Messages.OrderBook do
  alias PoloniexWebsocket.Utils, as: Utils

  def from_market_data([raw_asks, raw_bids], nonce, timestamp) do
    Map.merge(default_map, %{
      recorded_at: timestamp,
      nonce: nonce,
      bids: process_raw_book(raw_bids),
      asks: process_raw_book(raw_asks)
    })
  end

  defp process_raw_book(data) do
    Enum.reduce(data, Map.new, fn({k, v}, acc) -> Map.put(acc, Utils.to_integer(k), Utils.to_integer(v)) end)
  end

  defp default_map do
    %{type: :order_book}
  end
end
