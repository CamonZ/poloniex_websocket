defmodule PoloniexWebsocket.MessageParser do
  alias PoloniexWebsocket.Messages.MarketEvent, as: MarketEvent

  def process(_, timestamp \\ nil)

  def process([channel | _], ts) when channel == 1010 do
    timestamp = ts || now()
    %{heartbeat: timestamp}
  end

  def process([channel | message], ts) when channel > 0 and channel < 1000 do
    timestamp = ts || now()

    message
    |> market_events(timestamp)
    |> Map.put(:channel, channel)
  end

  def process([channel | _],_) do
    raise ArgumentError, message: "Unparseable message on channel #{channel}"
  end

  defp market_events(message, timestamp) do
    MarketEvent.from_message(message, timestamp)
  end

  defp now(), do: DateTime.utc_now()
end
