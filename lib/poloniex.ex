defmodule Poloniex do
  use WebSockex

  alias Poloniex.MessageParser, as: MessageParser

  ## Client API

  def start_link(state \\ %{})

  def start_link(%{callback: {m, f}, channels: %{}} = state) when not is_nil(m) and is_atom(f) do
    WebSockex.start_link(api_url(), __MODULE__, state)
  end

  def start_link(_) do
    raise "No callback specified"
  end

  def subscribe_to_currency(client, pair) do
    frame = pair |> subscription_message
    send_frame(client, frame)
  end

  ## Callbacks

  def handle_frame({_type, msg}, state) do
    state = Poison.decode!(msg) |> MessageParser.process(state) |> handle_data(state)
    {:ok, state}
  end

  defp handle_data(%{heartbeat: timestamp}, state) do
    Map.put(state, :last_heartbeat, timestamp)
  end

  defp handle_data(%{events: _, currency: currency} = args, %{callback: {m, f}, channels: channels} = state) when is_nil(currency)  do
    currency = Map.get(channels, args[:channel])
    apply(m, f, [Map.put(args, :currency, currency)])
    state
  end

  defp handle_data(%{events: _, currency: currency} = args, %{callback: {m, f}} = state) do
    apply(m, f, [args])
    channels = Map.put(state[:channels], args[:channel], currency)
    Map.put(state, :channels, channels)
  end

  ## Private functions

  defp send_frame(pid, frame) do
    WebSockex.send_frame(pid, frame)
  end

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
