defmodule Resty.MixProject do
  use Mix.Project

  def project do
    [
      app: :resty,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fakes"]
  defp elixirc_paths(:dev), do: ["lib", "test/fakes"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Move to jason
      {:excoveralls, "~> 0.10", only: :test},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"}
      # {:inflex, "~> 1.10.0"}
    ]
  end
end
