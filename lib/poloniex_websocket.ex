defmodule PoloniexWebsocket do
  use WebSockex
  alias PoloniexWebsocket.{DataHandler, MessageParser}
  defstruct markets: [], conn: nil, data_handler: nil

  @api_url "wss://api2.poloniex.com/"

  ## Client API

  def start_link(state, consumers \\ [])

  def start_link(%PoloniexWebsocket{markets: markets} = state, consumers) when length(markets) > 0 do
    {:ok, data_handler} = DataHandler.start_link(%DataHandler{consumers: consumers})
    Process.link(data_handler)

    WebSockex.start_link(@api_url, __MODULE__, Map.put(state, :data_handler, data_handler))
  end

  def start_link(_, _), do: raise "No Markets Specified"

  def subscribe_to_market(client, market) do
    frame = market |> subscription_frame()
    send_frame(client, frame)
  end

  def register_consumer(client, consumer) do
    WebSockex.cast(client, {:register_consumer, consumer})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__, start: {__MODULE__, :start_link, opts}, type: :worker,
      restart: :permanent, shutdown: :brutal_kill
    }
  end

  ## Callbacks

  def handle_connect(conn, %PoloniexWebsocket{markets: markets} = state) when length(markets) > 0 do
    Enum.each(markets, fn(market) -> sync_send(conn, subscription_frame(market)) end)
    {:ok, Map.put(state, :conn, conn)}
  end

  def handle_frame({_type, msg}, state) do
    events = msg |> Poison.decode!() |> MessageParser.process()
    DataHandler.data_received(state.data_handler, events)
    {:ok, state}
  end

  def handle_cast({:register_consumer, consumer}, state) do
    DataHandler.register_consumer(state.data_handler, consumer)
    {:ok, state}
  end

  def handle_info({:ssl_closed, _}, state), do: {:close, state}
  def handle_disconnect(_, state), do: {:ok, state}

  ## Private functions

  defp send_frame(client, frame), do: WebSockex.send_frame(client, frame)
  defp subscription_frame(currency), do: build_frame("subscribe", currency)
  defp build_frame(command, currency), do: { :text, Poison.encode!(%{command: command, channel: currency}) }

  defp sync_send(conn, frame) do
    with {:ok, binary_frame} <- WebSockex.Frame.encode_frame(frame),
      do: WebSockex.Conn.socket_send(conn, binary_frame)
  end
end
