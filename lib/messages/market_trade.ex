defmodule PoloniexWebsocket.Messages.MarketTrade do
  alias PoloniexWebsocket.Utils, as: Utils

  def from_market_data([trade_id, side, rate, amount, trade_timestamp], nonce, timestamp) when side == 0 do
    Map.merge(default_map, %{
      nonce: nonce,
      side: "sell",
      trade_id: trade_id,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      trade_timestamp: DateTime.from_unix!(trade_timestamp) |> DateTime.to_string,
      recorded_at: timestamp |> DateTime.to_string
    })
  end

  def from_market_data([trade_id, side, rate, amount, trade_timestamp], nonce, timestamp) when side == 1 do
    Map.merge(default_map, %{
      nonce: nonce,
      side: "buy",
      trade_id: trade_id,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      trade_timestamp: DateTime.from_unix!(trade_timestamp) |> DateTime.to_string,
      recorded_at: timestamp |> DateTime.to_string
    })
  end

  defp default_map do
    %{type: :market_trade}
  end
end
