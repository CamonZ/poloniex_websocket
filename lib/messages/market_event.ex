defmodule Poloniex.Messages.MarketEvent do
  alias Poloniex.Messages.OrderBook, as: OrderBook
  alias Poloniex.Messages.OrderBookUpdate, as: OrderBookUpdate
  alias Poloniex.Messages.MarketTrade, as: MarketTrade

  def build_events([nonce | events], timestamp) when is_integer(nonce) do
    process_events(hd(events), nonce, timestamp)
  end

  def build_events(_list, _timestamp) do
    []
  end

  defp process_events([[type | event_details]| rest], nonce, timestamp) when type == "o" do
    [build_order_book_update(event_details, nonce, timestamp) | process_events(rest, nonce, timestamp) ]
  end

  defp process_events([[type | event_details] | rest], nonce, timestamp) when type == "t" do
    [build_market_trade(event_details, nonce, timestamp) | process_events(rest, nonce, timestamp) ]
  end

  defp process_events([[type | [event_details | _]] | _], nonce, timestamp) when type == "i" do
    [build_order_book(event_details["orderBook"], nonce, timestamp)]
  end

  defp process_events(_, _, _) do
    []
  end

  defp build_order_book_update([side, rate, amount], nonce, timestamp) when side == 1 do
    %OrderBookUpdate{
      nonce: nonce,
      side: :bid,
      rate: to_integer(rate),
      amount: to_integer(amount),
      timestamp: timestamp
    }
  end

  defp build_order_book_update([side, rate, amount], nonce, timestamp) when side == 0 do
    %OrderBookUpdate{
      nonce: nonce,
      side: :ask,
      rate: rate,
      amount: amount,
      timestamp: timestamp
    }
  end

  defp build_market_trade([trade_id, side, rate, amount, trade_timestamp], nonce, timestamp) when side == 0 do
    %MarketTrade{
      nonce: nonce,
      side: :sell,
      trade_id: trade_id,
      rate: to_integer(rate),
      amount: to_integer(amount),
      trade_timestamp: trade_timestamp,
      timestamp: timestamp
    }
  end

  defp build_market_trade([trade_id, side, rate, amount, trade_timestamp], nonce, timestamp) when side == 1 do
    %MarketTrade{
      nonce: nonce,
      side: :buy,
      trade_id: trade_id,
      rate: to_integer(rate),
      amount: to_integer(amount),
      trade_timestamp: trade_timestamp,
      timestamp: timestamp
    }
  end

  defp build_order_book([raw_asks, raw_bids], nonce, timestamp) do
    %OrderBook{
      timestamp: timestamp,
      nonce: nonce,
      bids: process_raw_book(raw_bids),
      asks: process_raw_book(raw_asks)
    }
  end

  defp process_raw_book(data) do
    Enum.reduce(data, Map.new, fn({k, v}, acc) -> Map.put(acc, to_integer(k), to_integer(v)) end)
  end

  defp to_integer(num) do
    parts = String.split(num, ".") |> Enum.reverse

    [String.duplicate("0", 8-String.length(hd(parts))) | parts] |>
      Enum.reverse |>
      Enum.join |>
      Integer.parse |>
      elem(0)
  end
end
