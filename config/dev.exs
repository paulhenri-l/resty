use Mix.Config

# config :resty, adapter: Fakes.TestAdapter
config :resty, adapter: Resty.Adapters.HTTPoison
