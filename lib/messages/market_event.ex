defmodule PoloniexWebsocket.Messages.MarketEvent do
  alias PoloniexWebsocket.Messages.OrderBook, as: OrderBook
  alias PoloniexWebsocket.Messages.OrderBookUpdate, as: OrderBookUpdate
  alias PoloniexWebsocket.Messages.MarketTrade, as: MarketTrade

  def from_message([nonce | events], timestamp) when is_integer(nonce) do
    build_events(hd(events), nonce, timestamp) |> wrap_result()
  end

  def from_message(_, _), do: []

  defp wrap_result(result) do
    case is_map(result) do
      true -> result
      false -> %{ events: result, currency: nil }
    end
  end

  defp build_events([[type | data]| rest], nonce, timestamp) when type == "o" or type == "t" do
    event = case type do
      "o" -> OrderBookUpdate.from_market_data(data, nonce, timestamp)
      "t" -> MarketTrade.from_market_data(data, nonce, timestamp)
    end

    [event | build_events(rest, nonce, timestamp)]
  end

  defp build_events([[type | [data | _]] | _], nonce, timestamp) when type == "i" do
    order_book = OrderBook.from_market_data(data["orderBook"], nonce, timestamp)

    %{currency: data["currencyPair"], events: [order_book]}
  end

  defp build_events(_, _, _) do
    []
  end
end
