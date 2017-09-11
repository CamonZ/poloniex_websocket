defmodule Poloniex.Messages.MarketEvent do
  alias Poloniex.Messages.OrderBook, as: OrderBook
  alias Poloniex.Messages.OrderBookUpdate, as: OrderBookUpdate
  alias Poloniex.Messages.MarketTrade, as: MarketTrade

  def build_events([nonce | events], timestamp) when is_integer(nonce) do
    process_events(hd(events), nonce, timestamp) |> wrap_result
  end

  def build_events(_, _, _) do
    []
  end

  defp wrap_result(result) when is_map(result) do
    result
  end

  defp wrap_result(result) do
    %{ events: result }
  end

  defp process_events([[type | event_details]| rest], nonce, timestamp) when type == "o" do
    [OrderBookUpdate.from_market_data(event_details, nonce, timestamp) | process_events(rest, nonce, timestamp)]
  end

  defp process_events([[type | event_details] | rest], nonce, timestamp) when type == "t" do
    [MarketTrade.from_market_data(event_details, nonce, timestamp) | process_events(rest, nonce, timestamp)]
  end

  defp process_events([[type | [event_details | _]] | _], nonce, timestamp) when type == "i" do
    %{
      currency: event_details["currencyPair"],
      events: [OrderBook.from_market_data(event_details["orderBook"], nonce, timestamp)]
    }
  end

  defp process_events(_, _, _) do
    []
  end
end
