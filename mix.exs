defmodule Resty.MixProject do
  use Mix.Project

  def project do
    [
      app: :resty,
      version: "0.8.1",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      description: "Like ActiveResource but for Elixir",
      package: package(),

      # Docs
      name: "Resty",
      source_url: "https://github.com/paulhenri-l/resty",
      homepage_url: "https://github.com/paulhenri-l/resty",
      docs: [
        main: "readme",
        extras: ["README.md"],
        groups_for_modules: [
          Config: [
            Resty
          ],
          "The Basics": [
            Resty.Repo,
            Resty.Resource,
            Resty.Resource.Base
          ],
          Auth: [
            Resty.Auth,
            Resty.Auth.Basic,
            Resty.Auth.Bearer,
            Resty.Auth.Null
          ],
          Serializer: [
            Resty.Serializer,
            Resty.Serializer.Json
          ],
          Connection: [
            Resty.Connection,
            Resty.Connection.HTTPoison,
            Resty.Request
          ]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["paulhenri-l"],
      links: %{github: "https://github.com/paulhenri-l/resty"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fakes"]
  defp elixirc_paths(:dev), do: ["lib", "test/fakes"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.4"}
      # {:inflex, "~> 1.10.0"}
    ]
  end
end
