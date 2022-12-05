defmodule ExStacks.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_stacks,
      version: "0.1.0",
      description: "An elixir package to interact with the Stacks Blockchain",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),

      # Docs
      name: "Elixir Stacks",
      source_url: "https://github.com/Geeks-Solutions/ex_stacks",
      docs: [
        main: "ExStacks", # The main page in the docs
        extras: ["README.md"]
      ]
    ]
  end

  defp package() do
    [
      organization: "geeks_solutions",
      links: %{"GitHub" => "https://github.com/Geeks-Solutions/ex_stacks",
              "Website" => "https://www.stacks.co/",
              "Example" => "https://github.com/Geeks-Solutions/ex_stacks_example"}
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExStacks.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.6"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:cowboy, "~> 2.9"},
      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.5"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 5.0"},
      {:websockex, "~> 0.4.3"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
