defmodule Poloniex.Messages.MarketTrade do
  alias Poloniex.Utils, as: Utils
  alias __MODULE__

  defstruct trade_id: nil,
    side: nil,
    rate: nil,
    amount: nil,
    nonce: nil,
    timestamp: nil,
    trade_timestamp: nil

  def from_market_data([trade_id, side, rate, amount, trade_timestamp], nonce, timestamp) when side == 0 do
    %MarketTrade{
      nonce: nonce,
      side: :sell,
      trade_id: trade_id,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      trade_timestamp: trade_timestamp,
      timestamp: timestamp
    }
  end

  def from_market_data([trade_id, side, rate, amount, trade_timestamp], nonce, timestamp) when side == 1 do
    %MarketTrade{
      nonce: nonce,
      side: :buy,
      trade_id: trade_id,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      trade_timestamp: trade_timestamp,
      timestamp: timestamp
    }
  end
end
