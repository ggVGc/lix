defmodule Lix.MixProject do
  use Mix.Project

  def project do
    [
      app: :lix,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Lix.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exsync, "~> 0.4", only: :dev},
      {:oscx, "~> 0.1.1"},
      {:midiex, "~> 0.6.3"}
    ]
  end
end
