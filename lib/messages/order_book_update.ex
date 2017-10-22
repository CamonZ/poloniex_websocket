defmodule PoloniexWebsocket.Messages.OrderBookUpdate do
  alias PoloniexWebsocket.Utils, as: Utils

  def from_market_data([side_val, rate, amount], nonce, timestamp) do

    %{
      type: :order_book_update,
      nonce: nonce,
      rate: Utils.to_integer(rate),
      amount: Utils.to_integer(amount),
      recorded_at: timestamp |> DateTime.to_string()
    }
    |> Map.merge(book_side(side_val))
  end

  defp book_side(side_val) when side_val == 0, do: %{side: "ask"}
  defp book_side(side_val) when side_val == 1, do: %{side: "bid"}
end
