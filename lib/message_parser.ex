defmodule Poloniex.MessageParser do
  alias Poloniex.Messages.MarketEvent, as: MarketEvent

  def process([channel | _]) when channel == 1010 do
    {:heartbeat, timestamp(), channel}
  end

  def process([channel | channel_message]) when channel > 0 and channel < 1000 do
    events = MarketEvent.build_events(channel_message, timestamp())
    {:market_event, events, channel}
  end

  defp timestamp do
    DateTime.utc_now |> DateTime.to_unix(:millisecond)
  end
end
