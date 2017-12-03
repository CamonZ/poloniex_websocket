defmodule PoloniexWebsocketTest do
  use ExUnit.Case
  alias PoloniexWebsocket
  doctest PoloniexWebsocket

  describe ".handle_data" do
    test "it updates the currencies to channels map in the server state when the currency map is empty" do
      json_message = "[117,92273022,[[\"i\",{\"currencyPair\":\"BTC_XRP\",\"orderBook\":[{\"0.00005128\":\"93.52483673\"},{\"0.00005127\":\"31.20655354\"}]}]]]"
      {:ok, state} = PoloniexWebsocket.handle_frame({ :text, json_message }, %PoloniexWebsocket{})

      assert Map.get(state.channels, 117) == "BTC_XRP"
    end

    test "it assigns the currency symbol to the data when the currency map isn't empty" do
      now = DateTime.utc_now |> DateTime.to_string
      json_message = "[117,92261674,[[\"o\",0,\"0.00005136\",\"18.39534225\"]]]"
      PoloniexWebsocket.handle_frame({:text, json_message}, %PoloniexWebsocket{channels: %{117 => "BTC_XRP"}, consumers: [self()]})

      assert_received {:"$gen_cast", [%{market: market, events: events}]}
      assert market == "BTC_XRP"
      assert is_list(events)

      {extracted, rest} = Map.split(hd(events), [:side, :rate, :amount, :nonce])

      assert extracted == %{
        nonce: 92261674,
        side: "ask",
        rate: 5136,
        amount: 1839534225
        }

      assert Map.get(rest, :recorded_at) >= now
    end
  end
end
