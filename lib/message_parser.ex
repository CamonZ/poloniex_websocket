defmodule PoloniexFeed.MessageParser do
  def process([channel | _], state) when channel == 1010 do
    {:heartbeat, timestamp()}
  end

  def process([channel | channel_message], state) when channel > 0 and channel < 1000 do
    events = PoloniexFeed.Messages.MarketEvent.build_events(channel_message, timestamp())
    {:market_event, events}
  end

  defp timestamp do
    DateTime.utc_now |> DateTime.to_unix(:millisecond)
  end
end
