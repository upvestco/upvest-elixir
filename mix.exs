defmodule Upvest.MixProject do
  use Mix.Project
  @version "0.1.1"

  def project do
    [
      app: :upvest,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: not (Mix.env() in [:dev, :test]),
      deps: deps(),
      package: package(),
      source_url: "https://gitlab.com/rpip/upvest-elixir",
      homepage_url: "https://gitlab.com/rpip/upvest-elixir",
      description: "Elixir library for the Upvest API",
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"],
      docs: [
        main: "readme",
        extras: ["README.md"],
        groups_for_modules: groups_for_modules(),
        nest_modules_by_prefix: nest_modules_by_prefix()
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.5"},
      {:poison, "~> 4.0"},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      # Test
      # Docs      
      {:ex_doc, "~> 0.21.1", only: :docs, runtime: false},
      {:earmark, "~> 1.3.5", only: :docs, runtime: false},
      {:inch_ex, ">= 2.0.0", only: :docs, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG),
      maintainers: ["Yao Adzaku"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/rpip/upvest-elixir"}
    ]
  end

  defp groups_for_modules do
    [
      "Core Resources": [
        Upvest.API,
        Upvest.Client,
        Upvest.Utils,
        Upvest.AuthProvider
      ],
      "Tenancy API": [
        Upvest.Tenancy.User,
        Upvest.Tenancy.Asset
      ],
      "Clientele API": [
        Upvest.Clientele.Wallet,
        Upvest.Clientele.Transaction
      ],
      Authentication: [
        Upvest.AuthProvider,
        Upvest.Authentication.KeyAuth,
        Upvest.Authentication.OAuth
      ],
      Errors: [
        Upvest.APIConnectionError,
        Upvest.AuthenticationError,
        Upvest.InvalidRequestError,
        Upvest.PermissionError,
        Upvest.APIError
      ]
    ]
  end

  def nest_modules_by_prefix() do
    [
      Upvest.Authentication,
      Upvest.Authentication.KeyAuth,
      Upvest.Authentication.OAuth
    ]
  end
end
