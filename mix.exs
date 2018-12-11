defmodule Huex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :huex,
      version: "0.8.0",
      elixir: "~> 1.1",
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/xavier/huex",
      homepage_url: "https://github.com/xavier/huex"
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 3.0"},
      {:nerves_ssdp_client, "~> 0.1", optional: true},
      {:exvcr, "~> 0.8.0", only: :test},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp description do
    "Elixir client for Philips Hue connected light bulbs"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "examples"],
      maintainers: ["Xavier Defrang"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/xavier/huex"}
    ]
  end
end
