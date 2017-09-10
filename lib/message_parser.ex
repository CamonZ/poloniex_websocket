defmodule Poloniex.MessageParser do
  alias Poloniex.Messages.MarketEvent, as: MarketEvent

  def process([channel | _], timestamp \\ nil) when channel == 1010 do
    if timestamp == nil  do
      timestamp = now()
    end

    {:heartbeat, timestamp, channel}
  end

  def process([channel | channel_message], timestamp \\ nil) when channel > 0 and channel < 1000 do
    if timestamp == nil  do
      timestamp = now()
    end

    events = MarketEvent.build_events(channel_message, timestamp)

    {:market_event, events, channel}
  end

  defp now do
    DateTime.utc_now |> DateTime.to_unix(:millisecond)
  end
end
