defmodule PoloniexFeed.Consumer do
  use WebSockex

  ## Client API

  def start_link(state \\ %{}) do
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

  def handle_disconnect(%{reason: {:local, _reason}}, state) do
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def handle_info(:check_heartbeat, _from, state) do
    %{last_heartbeat: heartbeat} = state
    now = DateTime.utc_now |> DateTime.to_unix(:millisecond)

    if (now - heartbeat > 10000)  do
      Process.exit(self(), :disconnected)
    else
      schedule_heartbeat_check()
    end

    {:noreply, state}
  end

  def handle_data({:heartbeat, timestamp}, state) do
    Map.put(state, :last_heartbeat, timestamp)
  end

  def handle_data({:market_event, events}, state) do
    # do something with the events here
    state
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

  defp schedule_heartbeat_check() do
    Process.send_after(self(), :check_heartbeat, 10000)
  end
end
