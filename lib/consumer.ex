defmodule PoloniexFeed.Consumer do
  use WebSockex

  ## Client API

  def start_link(state \\ %{}) do
    WebSockex.start_link(api_url(), __MODULE__, state)
  end

  def subscribe_to_currency(client, pair) do
    frame = pair |> subscription_to_currency_channel_message
    send_frame(client, frame)
  end

  def send_frame(pid, frame) do
    WebSockex.send_frame(pid, frame)
  end

  ## Callbacks

  def handle_frame({_type, msg}, state) do
    Poison.decode!(msg) |> PoloniexFeed.MessageParser.process
    {:ok, state}
  end

  def handle_disconnect(%{reason: {:local, _reason}}, state) do
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  ## Private functions

  defp api_url do
    "wss://api2.poloniex.com/"
  end

  defp subscription_to_currency_channel_message(currency) do
    %{command: "subscribe", channel: currency} |>
      encode_message
  end

  defp encode_message(hsh) do
    {:text, Poison.encode!(hsh) }
  end
end
