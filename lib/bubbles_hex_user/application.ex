defmodule BubblesHexUser.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BubblesHexUserWeb.Telemetry,
      BubblesHexUser.Repo,
      {DNSCluster, query: Application.get_env(:bubbles_hex_user, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BubblesHexUser.PubSub},
      # Start a worker by calling: BubblesHexUser.Worker.start_link(arg)
      # {BubblesHexUser.Worker, arg},
      # Start to serve requests, typically the last entry
      BubblesHexUserWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BubblesHexUser.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BubblesHexUserWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
