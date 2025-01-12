defmodule Server.MixProject do
  use Mix.Project

  def project do
    [
      app: :tpro_maintanance,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools, :tools],
      mod: {Server.Application, []}
    ]
  end

  defp deps do
    [
      {:xrpc, git: "git@gitlab.com:tender.pro/elixir-utils/xrpc.git", ref: "uz_dev"},
#      {:xevent, git: "git@gitlab.com:tender.pro/elixir-utils/xevent.git", ref: "dev"},
#      {:helpers, git: "git@gitlab.com:tender.pro/elixir-utils/helpers.git"},
      {:plug_cowboy, "~> 2.5"},
      {:gettext, ">= 0.11.0"},
      {:jason, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_view, "~> 0.20"},
      {:httpoison, "~> 1.8.2", override: true}
    ]
  end
end
