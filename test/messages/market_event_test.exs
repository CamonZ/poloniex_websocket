defmodule PoloniexFeed.Messages.MarketEventTest do
  use ExUnit.Case

  alias PoloniexFeed.Messages.OrderBook, as: OrderBook
  alias PoloniexFeed.Messages.OrderBookUpdate, as: OrderBookUpdate
  alias PoloniexFeed.Messages.MarketTrade, as: MarketTrade

  doctest PoloniexFeed.Messages.MarketEvent

  test "builds an order book update" do
    data = [90077516, [["o",1,"0.00004962","0.00000150"]]]
    assert PoloniexFeed.Messages.MarketEvent.build_events(data, 1504556374) == [%OrderBookUpdate{
      nonce: 90077516,
      side: :bid,
      rate: 4962,
      amount: 150,
      timestamp: 1504556374
    }]
  end

  test "builds a market trade update" do
    data = [90077516, [["t","13000395",1,"0.00004995","0.00000660",1504480453]]]
    assert PoloniexFeed.Messages.MarketEvent.build_events(data, 1504556374) == [%MarketTrade{
      nonce: 90077516,
      side: :buy,
      rate: 4995,
      amount: 660,
      trade_id: "13000395",
      trade_timestamp: 1504480453,
      timestamp: 1504556374
    }]
  end

  test "builds the order book" do
    data = [
      27366912,
      [
        [
          "i", %{
            "currencyPair" => "BTC_STRAT",
            "orderBook" => [
              %{ "0.00134216" => "1.71288737", "0.00134232" => "13.35069928" },
              %{ "0.00134000" => "1659.01646269", "0.00133188" => "0.52557287" }
            ]
          }
        ]
      ]
    ]

    assert PoloniexFeed.Messages.MarketEvent.build_events(data, 1504556374) == [%OrderBook{
      nonce: 27366912,
      timestamp: 1504556374,
      bids: %{
        134000 => 165901646269,
        133188 => 52557287
      },
      asks: %{
        134216 => 171288737,
        134232 => 1335069928
      }
    }]
  end
end
