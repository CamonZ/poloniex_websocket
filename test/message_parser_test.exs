defmodule Poloniex.MessageParserTest do
  use ExUnit.Case
  alias Poloniex.MessageParser, as: MessageParser
  alias Poloniex.Messages.OrderBookUpdate, as: OrderBookUpdate
  alias Poloniex.Messages.MarketTrade, as: MarketTrade

  doctest Poloniex.MessageParser

  test "processes a heartbeat message" do
    now = DateTime.utc_now |> DateTime.to_unix(:millisecond)
    data = [1010, []]

    assert MessageParser.process(data, now) == {:heartbeat, now, 1010}
  end

  test "processes order book updates and trade update messages" do
    now = DateTime.utc_now |> DateTime.to_unix(:millisecond)
    data = [121,128109982,[["o",0,"0.00000130","0.00000100"],["t","8279109",1,"0.00000130","0.00000100",1504999563]]]

    {:market_event, [book_update, market_trade], 121} = MessageParser.process(data, now)

    assert book_update == %OrderBookUpdate{
      nonce: 128109982,
      side: :ask,
      rate: 130,
      amount: 100,
      timestamp: now
    }

    assert market_trade == %MarketTrade{
      nonce: 128109982,
      side: :buy,
      rate: 130,
      amount: 100,
      trade_id: "8279109",
      trade_timestamp: 1504999563,
      timestamp: now
    }

  end
end
