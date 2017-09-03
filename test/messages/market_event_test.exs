defmodule PoloniexFeed.Messages.MarketEventTest do
  use ExUnit.Case
  doctest PoloniexFeed.Messages.MarketEvent

  test "builds an order book update" do
    data = [[["o",1,"0.00004962","18599.42077102"]]]
    assert PoloniexFeed.Messages.MarketEvent.build_events(data) != nil
  end
end
