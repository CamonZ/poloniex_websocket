defmodule PoloniexWebsocket.MessageParser do
  alias PoloniexWebsocket.Messages.MarketEvent, as: MarketEvent

  def process(_, timestamp \\ nil)

  def process([channel | _], timestamp) when channel == 1010 and is_nil(timestamp) do
    %{heartbeat: now()}
  end

  def process([channel | _], timestamp) when channel == 1010 do
    %{heartbeat: timestamp}
  end

  def process([channel | message], timestamp) when channel > 0 and channel < 1000 and is_nil(timestamp) do
    Map.put(market_events(message, now()), :channel, channel)
  end

  def process([channel | message], timestamp) when channel > 0 and channel < 1000 do
    Map.put(market_events(message, timestamp), :channel, channel)
  end

  defp market_events(message, timestamp) do
    MarketEvent.build_events(message, timestamp)
  end

  defp now do
    DateTime.utc_now
  end
end
