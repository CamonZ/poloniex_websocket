defmodule Poloniex do
  use WebSockex

  alias Poloniex.MessageParser, as: MessageParser

  ## Client API

  def start_link(state \\ %{})

  def start_link(%{callback: {m, f}, channels: %{}} = state) when not is_nil(m) and is_atom(f) do
    WebSockex.start_link(api_url(), __MODULE__, Map.put(state, :channels, %{}))
  end

  def start_link(_) do
    raise "No callback specified"
  end

  def subscribe_to_currency(client, currency_pair) do
    currency_pair |> build_subscription_frame |> send_frame(client)
  end

  ## Callbacks

  def handle_connect(_conn, %{currencies: currencies}) do
    if !empty?(currencies) do
      Enum.each(currencies, fn(currency) -> subscribe_to_currency(self(), currency) end)
    end
  end

  def handle_frame({_type, msg}, state) do
    state = Poison.decode!(msg) |> MessageParser.process(state) |> handle_data(state)
    {:ok, state}
  end

  defp handle_data(%{heartbeat: timestamp}, state) do
    Map.put(state, :last_heartbeat, timestamp)
  end

  defp handle_data(%{events: _, currency: currency} = args, %{callback: {m, f}, channels: channels} = state) when is_nil(currency)  do
    currency = Map.get(channels, args[:channel])
    apply(m, f, wrapped_events(Map.put(args, :currency, currency)))
    state
  end

  defp handle_data(%{events: _, currency: currency} = args, %{callback: {m, f}} = state) do
    apply(m, f, wrapped_events(args))
    channels = Map.put(state[:channels], args[:channel], currency)
    Map.put(state, :channels, channels)
  end

  ## Private functions

  defp send_frame(frame, pid) do
    WebSockex.send_frame(pid, frame)
  end

  defp wrapped_events(%{events: events, currency: currency } = args) do
    [%{events: events, currency: currency}]
  end

  defp api_url do
    "wss://api2.poloniex.com/"
  end

  defp build_subscription_frame(currency) do
    { :text, Poison.encode(%{command: "subscribe", channel: currency}) }
  end
end
