defmodule PoloniexFeed.MessageParser do
  def process([channel | _tl] = _message) when channel == 1010 do
    heartbeat_message
  end

  def process([channel | channel_message] = _message) when channel > 0 and channel < 1000 do
    _events = PoloniexFeed.Messages.MarketEvent.build_events(channel_message, channel)
  end

  defp heartbeat_message do
    now = DateTime.utc_now |> DateTime.to_string
    IO.puts "#{now}"
  end
end
