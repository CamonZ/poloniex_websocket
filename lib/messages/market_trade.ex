defmodule PoloniexWebsocket.Messages.MarketTrade do
  alias PoloniexWebsocket.Utils, as: Utils

  def from_market_data([_, side_val | _] = market_update, nonce, timestamp) do
    base_map(market_update, nonce, timestamp)
    |> Map.merge(trade_side(side_val))
  end

  defp base_map([trade_id, _, rate, amount, trade_timestamp], nonce, timestamp) do
    %{
      type: :market_trade,
      nonce: nonce,
      trade_id: trade_id,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      trade_timestamp: DateTime.from_unix!(trade_timestamp) |> DateTime.to_string,
      recorded_at: timestamp |> DateTime.to_string
    }
  end

  defp trade_side(side_val) when side_val == 0, do: %{side: "sell"}
  defp trade_side(side_val) when side_val == 1, do: %{side: "buy"}
end
