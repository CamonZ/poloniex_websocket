defmodule Poloniex.Messages.OrderBookUpdate do
  alias Poloniex.Utils, as: Utils
  alias __MODULE__

  defstruct side: nil, rate: nil, amount: nil, nonce: nil, timestamp: nil

  def from_market_data([side, rate, amount], nonce, timestamp) when side == 1 do
    %OrderBookUpdate{
      nonce: nonce,
      side: :bid,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      timestamp: timestamp
    }
  end

  def from_market_data([side, rate, amount], nonce, timestamp) when side == 0 do
    %OrderBookUpdate{
      nonce: nonce,
      side: :ask,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      timestamp: timestamp
    }
  end
end
