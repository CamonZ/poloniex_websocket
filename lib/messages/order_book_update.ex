defmodule PoloniexWebsocket.Messages.OrderBookUpdate do
  alias PoloniexWebsocket.Utils, as: Utils

  def from_market_data([side, rate, amount], nonce, timestamp) when side == 1 do
    Map.merge(default_map, %{
      nonce: nonce,
      side: :bid,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      timestamp: timestamp
    })
  end

  def from_market_data([side, rate, amount], nonce, timestamp) when side == 0 do
    Map.merge(default_map, %{
      nonce: nonce,
      side: :ask,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      timestamp: timestamp
    })
  end

  defp default_map do
    %{type: :order_book_update}
  end
end
