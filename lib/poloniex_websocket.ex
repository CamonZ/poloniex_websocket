defmodule PoloniexWebsocket do
  use WebSockex

  alias PoloniexWebsocket.MessageParser, as: MessageParser

  defstruct consumers: [], markets: [], conn: nil, last_heartbeat: nil, channels: %{}

  ## Client API

  def start_link(state \\ %PoloniexWebsocket{})

  def start_link(%PoloniexWebsocket{markets: markets} = state) when length(markets) > 0, do:
    WebSockex.start_link(api_url(), __MODULE__, state)

  def start_link(_), do: raise "No Markets Specified"

  def subscribe_to_market(client, market) do
    frame = market |> subscription_frame
    send_frame(client, frame)
  end

  def register_consumer(client, consumer) do
    WebSockex.cast(client, {:register_consumer, consumer})
  end

  ## Callbacks

  def handle_connect(conn, %PoloniexWebsocket{markets: markets} = state) when length(markets) > 0 do
    Enum.each(markets, fn(market) -> sync_send(conn, subscription_frame(market)) end)
    {:ok, Map.put(state, :conn, conn)}
  end

  def handle_frame({_type, msg}, state) do
    state = Poison.decode!(msg) |> MessageParser.process |> handle_data(state)
    {:ok, state}
  end


  defp handle_data(%{heartbeat: timestamp}, state) do
    Map.put(state, :last_heartbeat, timestamp)
  end

  defp handle_data(%{events: _, market: events_market} = args, state) when is_nil(events_market)  do
    %PoloniexWebsocket{channels: channels, consumers: consumers} = state

    market = Map.get(channels, args[:channel])
    notify_consumers(consumers, wrapped_events(Map.put(args, :market, market)))

    state
  end

  defp handle_data(%{events: _, market: market} = args, state) do
    %PoloniexWebsocket{consumers: consumers} = state

    notify_consumers(consumers, wrapped_events(args))

    channels = Map.put(state.channels, args[:channel], market)
    Map.put(state, :channels, channels)
  end

  def handle_cast({:register_consumer, consumer}, %PoloniexWebsocket{consumers: consumers} = state) do
    {:ok, Map.put(state, :consumers, [consumer | consumers])}
  end

  def handle_info({:ssl_closed, _}, state), do: {:close, state}
  def handle_disconnect(_, state), do: {:ok, state}

  ## Private functions

  defp send_frame(client, frame), do: WebSockex.send_frame(client, frame)
  defp wrapped_events(%{events: events, market: market }), do: [%{events: events, market: market}]
  defp api_url, do: "wss://api2.poloniex.com/"
  defp subscription_frame(currency), do: build_frame("subscribe", currency)
  defp build_frame(command, currency), do: { :text, Poison.encode!(%{command: command, channel: currency}) }
  defp notify_consumers(consumers, events), do: Enum.each(consumers, fn(consumer) -> GenServer.cast(consumer, events) end)

  defp sync_send(conn, frame) do
    with {:ok, binary_frame} <- WebSockex.Frame.encode_frame(frame),
      do: WebSockex.Conn.socket_send(conn, binary_frame)
  end
end
