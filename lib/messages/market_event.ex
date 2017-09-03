defmodule PoloniexFeed.Messages.MarketEvent do
  defmodule OrderBook do
    defstruct bids: %{}, asks: %{}, timestamp: nil, nonce: nil
  end

  defmodule OrderBookUpdate do
    defstruct side: nil, rate: nil, amount: nil, nonce: nil, timestamp: nil
  end

  defmodule MarketTrade do
    defstruct trade_id: nil, side: nil, rate: nil, amount: nil, nonce: nil, timestamp: nil
  end

  def build_events([nonce | events], _channel) when is_integer(nonce) do
    process_events(hd(events), nonce)
  end

  def build_events(_list, _channel) do
    []
  end

  defp process_events([event | rest], nonce) when hd(event) == "o" do
    [_type | event_details] = event
    [build_order_book_update(event_details, nonce) | process_events(rest, nonce) ]
  end

  defp process_events([event | rest], nonce) when hd(event) == "t" do
    [_type | event_details] = event
    [build_market_trade(event_details, nonce) | process_events(rest, nonce) ]
  end

  defp process_events([event | rest], nonce) when hd(event) == "i" do
    [_type | event_details] = event
    [build_order_book(event_details, nonce) | process_events(rest, nonce) ]
  end

  defp process_events(_arr, _nonce) do
    []
  end

  defp build_order_book_update([side, rate, amount], nonce) when side == 1 do
    %OrderBookUpdate{side: :bid, rate: to_integer(rate), amount: to_integer(amount), nonce: nonce, timestamp: DateTime.utc_now}
  end

  defp build_order_book_update([side, rate, amount], nonce) when side == 0 do
    %OrderBookUpdate{side: :ask, rate: rate, amount: amount, nonce: nonce, timestamp: DateTime.utc_now}
  end

  defp build_market_trade([trade_id, s, rate, amount, timestamp], nonce) when s == 0 do
    %MarketTrade{trade_id: trade_id, side: :sell, rate: to_integer(rate), amount: to_integer(amount), timestamp: timestamp}
  end

  defp build_market_trade([trade_id, s, rate, amount, timestamp], nonce) when s == 1 do
    %MarketTrade{trade_id: trade_id, side: :buy, rate: to_integer(rate), amount: to_integer(amount), timestamp: timestamp}
  end

  defp build_order_book(details, _nonce) do
    IO.puts("Order Book: #{inspect details}")
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
