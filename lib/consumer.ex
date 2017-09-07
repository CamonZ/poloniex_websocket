defmodule PoloniexFeed.Consumer do
  use WebSockex

  ## Client API

  def start_link(state \\ %{received_messages: 0}) do
    WebSockex.start_link(api_url(), __MODULE__, state)
  end

  def subscribe_to_currency(client, pair) do
    frame = pair |> subscription_message
    send_frame(client, frame)
  end

  def send_frame(pid, frame) do
    WebSockex.send_frame(pid, frame)
  end

  ## Callbacks

  def handle_frame({_type, msg}, state) do
    state = Poison.decode!(msg) |> PoloniexFeed.MessageParser.process() |> handle_data(state)
    {:ok, state}
  end

  def handle_data({:heartbeat, timestamp, _}, state) do
    Map.put(state, :last_heartbeat, timestamp)
  end

  def handle_data({:market_event, _events, _}, state) do
    count = state[:received_messages] + 1
    IO.puts "Received #{count} Messages"
    Map.put(state, :received_messages, count)
  end

  ## Private functions

  defp api_url do
    "wss://api2.poloniex.com/"
  end

  defp subscription_message(currency) do
    %{command: "subscribe", channel: currency} |>
      encode_message
  end

  defp encode_message(hsh) do
    {:text, Poison.encode!(hsh) }
  end
end
