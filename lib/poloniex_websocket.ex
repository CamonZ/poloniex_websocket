defmodule PoloniexWebsocket do
  use WebSockex

  alias PoloniexWebsocket.MessageParser, as: MessageParser

  ## Client API

  def start_link(state \\ %{})

  def start_link(%{callback: {m, f}} = state) when not is_nil(m) and is_atom(f), do:
    WebSockex.start_link(api_url(), __MODULE__, Map.put(state, :channels, %{}))

  def start_link(_), do:
    raise "No callback specified"

  def subscribe_to_currency(client, currency_pair) do
    currency_pair |> build_subscription_frame |> send_frame(client)
  end

  ## Callbacks

  def handle_connect(conn, state) do
    currencies = state[:currencies] || []

    if !Enum.empty?(currencies) do
      Enum.each(currencies, fn(currency) ->
        frame = build_subscription_frame(currency)
        sync_send(conn, frame)
      end)
    end
    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    state = Poison.decode!(msg) |> MessageParser.process |> handle_data(state)
    {:ok, state}
  end

  def handle_info({:ssl_closed} = message, state) do
    {:reconnect, state}
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
    { :text, Poison.encode!(%{command: "subscribe", channel: currency}) }
  end

  defp sync_send(conn, frame) do
    with {:ok, binary_frame} <- WebSockex.Frame.encode_frame(frame),
      do: WebSockex.Conn.socket_send(conn, binary_frame)
  end
end
