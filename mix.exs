defmodule Forklift.MixProject do
  use Mix.Project

  def project do
    [
      app: :forklift,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:mime, "~> 1.0"},
      {:depot, "~> 0.5.0"},
      {:jason, "~> 1.2", optional: true},
      {:plug, "~> 1.10", optional: true}
    ]
  end
end
