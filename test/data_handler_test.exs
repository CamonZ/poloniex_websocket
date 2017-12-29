defmodule DataHandlerTest do
  use ExUnit.Case
  alias PoloniexWebsocket.DataHandler

  doctest DataHandler

  describe ".handle_data" do
    test "it updates the currencies to channels map in the server state when the currency map is empty" do
      events = %{
        channel: 117,
        events: [%{
                    asks: %{5128 => 9352483673}, bids: %{5127 => 3120655354},
                    nonce: 92273022, recorded_at: "2017-12-29 15:58:12.578525Z",
                    type: :order_book
                 }],
        market: "BTC_XRP"
      }

      {:ok, state} = DataHandler.handle_cast({ :data_received, events }, %DataHandler{})

      assert Map.get(state.channels, 117) == "BTC_XRP"
    end

    test "it assigns the currency symbol to the data when the currency map isn't empty" do
      now = DateTime.utc_now |> DateTime.to_string

      data = %{channel: 117,
        events: [%{
                    amount: 1839534225, nonce: 92261674, rate: 5136,
                    recorded_at: now(), side: "ask",
                    type: :order_book_update
                 }],
        market: nil
      }

      DataHandler.handle_cast({ :data_received, data }, %DataHandler{channels: %{117 => "BTC_XRP"}, consumers: [self()]})

      assert_received {:"$gen_cast", {:market_events, [%{market: market, events: events}]}}
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
