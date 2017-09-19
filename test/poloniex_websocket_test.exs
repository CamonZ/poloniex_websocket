defmodule PoloniexWebsocketTest do
  use ExUnit.Case
  doctest PoloniexWebsocket

  describe ".handle_data" do
    test "it updates the currencies to channels map in the server state when the currency map is empty" do
      json_message = "[117,92273022,[[\"i\",{\"currencyPair\":\"BTC_XRP\",\"orderBook\":[{\"0.00005128\":\"93.52483673\"},{\"0.00005127\":\"31.20655354\"}]}]]]"
      {:ok, state} = PoloniexWebsocket.handle_frame({ :text, json_message }, %{ callback: {PoloniexWebsocketTest, :callback}, channels: %{}})

      assert Map.has_key?(state, :channels)
      assert Map.get(state[:channels], 117) == "BTC_XRP"
    end

    test "it assigns the currency symbol to the data when the currency map isn't empty" do
      json_message = "[117,92261674,[[\"o\",0,\"0.00005136\",\"18.39534225\"]]]"
      PoloniexWebsocket.handle_frame({ :text, json_message }, %{ callback: {PoloniexWebsocketTest, :callback}, channels: %{117 => "BTC_XRP" } })

      assert_received {:message_received, %{currency: currency, events: events}}
      assert currency == "BTC_XRP"
      assert is_list(events)

      {extracted, _} = Map.split(hd(events), [:side, :rate, :amount, :nonce])

      assert extracted == %{
        nonce: 92261674,
        side: "ask",
        rate: 5136,
        amount: 1839534225
      }
    end

    test "it calls the passed callback function in the state" do
      json_message = "[117,92261674,[[\"o\",0,\"0.00005136\",\"18.39534225\"]]]"
      PoloniexWebsocket.handle_frame({ :text, json_message }, %{ callback: {PoloniexWebsocketTest, :callback}, channels: %{117 => "BTC_XRP" } })

      assert_received {:message_received, _}
    end
  end

  def callback(events_data) do
    send(self(), {:message_received, events_data})
  end
end
