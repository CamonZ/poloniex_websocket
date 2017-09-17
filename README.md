# PoloniexWebsocket

Unofficial and experimental library for consuming market data via Poloniex's websocket connection

## Installation

Add the dependency to your mix.exs file

```elixir
def deps do
  [{:poloniex_websocket, "~> 0.0.1"}]
end
```

## Usage

Call `Poloniex.start_link()` with a map with the keys `callback` and `currencies`, the `callback` should be a tuple with a Module/Function, and `currencies` 
should be a list of currency pairs, e.g. `%{callback: {Foo, :callback}, currencies: ["USDT_BTC", "BTC_ETH", "BTC_LTC"]}`.
