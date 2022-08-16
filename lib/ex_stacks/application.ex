defmodule ExStacks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ExStacksWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExStacks.PubSub},
      # Start the Endpoint (http/https)
      ExStacksWeb.Endpoint
      # Start a worker by calling: ExStacks.Worker.start_link(arg)
      # {ExStacks.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExStacks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExStacksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
