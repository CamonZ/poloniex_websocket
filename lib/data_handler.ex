defmodule PoloniexWebsocket.DataHandler do
  use GenServer

  defstruct consumers: [], channels: %{}, last_heartbeat: nil
  alias PoloniexWebsocket.DataHandler

  def start_link(%DataHandler{} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def data_received(pid, events) do
    GenServer.cast(pid, {:data_received, events})
  end

  def register_consumer(pid, consumer) do
    GenServer.cast(pid, {:register_consumer, consumer})
  end

  def handle_cast({:register_consumer, consumer}, %DataHandler{consumers: consumers} = state) do
    {:noreply, Map.put(state, :consumers, [consumer | consumers])}
  end

  def handle_cast({:data_received, events}, state) do
    new_state = handle_data(events, state)
    {:noreply, new_state}
  end

  defp handle_data(%{heartbeat: timestamp}, state) do
    Map.put(state, :last_heartbeat, timestamp)
  end

  defp handle_data(
    %{events: _, market: market_name} = args,
    %DataHandler{channels: channels, consumers: consumers} = state) when is_nil(market_name)  do

    market = Map.get(channels, args[:channel])
    notify_consumers(consumers, wrapped_events(Map.put(args, :market, market)))

    state
  end

  defp handle_data(
    %{events: _, market: market_name, channel: channel_number} = args,
    %DataHandler{consumers: consumers} = state) do

    notify_consumers(consumers, wrapped_events(args))
    Map.put(state, :channels, updated_channels(state.channels, channel_number, market_name))
  end

  defp notify_consumers(consumers, events), do: Enum.each(consumers, &notify_consumer(&1, events))
  defp notify_consumer(consumer, events), do: GenServer.cast(consumer, {:market_events, events})
  defp wrapped_events(%{events: events, market: market }), do: [%{events: events, market: market}]
  defp updated_channels(channels_map, channel_number, market_name), do: Map.put(channels_map, channel_number, market_name)
end
