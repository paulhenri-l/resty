use Mix.Config

config :resty, connection: Fakes.TestConnection

config :resty, Resty.Auth.Basic, user: "conf-user", password: "conf-password"
config :resty, Resty.Auth.Bearer, token: "my-token-from-config"
