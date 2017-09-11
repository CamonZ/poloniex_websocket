defmodule Poloniex.Messages.OrderBook do
  alias Poloniex.Utils, as: Utils
  alias __MODULE__

  defstruct bids: %{}, asks: %{}, timestamp: nil, nonce: nil

  def from_market_data([raw_asks, raw_bids], nonce, timestamp) do
    %OrderBook{
      timestamp: timestamp,
      nonce: nonce,
      bids: process_raw_book(raw_bids),
      asks: process_raw_book(raw_asks)
    }
  end

  defp process_raw_book(data) do
    Enum.reduce(data, Map.new, fn({k, v}, acc) -> Map.put(acc, Utils.to_integer(k), Utils.to_integer(v)) end)
  end
end
