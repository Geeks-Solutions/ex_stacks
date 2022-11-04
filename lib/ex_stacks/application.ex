defmodule ExStacks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: ExStacks.DynamicSupervisor, strategy: :one_for_one}
    ]

    # create ETS table to handle subscribed processes
    :ets.new(:subscribed_processes, [:set, :public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExStacks.Supervisor]
    res = Supervisor.start_link(children, opts)
    # Start the Telemetry supervisor
    Enum.each(
      [
        ExStacksWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: ExStacks.PubSub}

        # Start a worker by calling: ExStacks.Worker.start_link(arg)
        # {ExStacks.Worker, arg}
      ],
      fn mod -> DynamicSupervisor.start_child(ExStacks.DynamicSupervisor, mod) end
    )

    res
  end

  @impl true
  def config_change(_changed, _new, _removed) do
    :ok
  end
end
