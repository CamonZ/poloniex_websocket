defmodule PoloniexWebsocket.Mixfile do
  use Mix.Project

  def project do
    [app: :poloniex_websocket,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     source_url: "https://github.com/CamonZ/poloniex_websocket",
     license: "MIT",
     description: description()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:websockex, "~> 0.4.0"},
      {:poison, "~> 3.1"}
    ]
  end

  defp description do
    "Unofficial and experimental library for consuming market data via Poloniex's websocket connection"
  end
end
