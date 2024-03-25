defmodule Krite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KriteWeb.Telemetry,
      Krite.Repo,
      {DNSCluster, query: Application.get_env(:krite, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Krite.PubSub},
      KriteWeb.Presence,
      # Start the Finch HTTP client for sending emails
      {Finch, name: Krite.Finch},
      # Start a worker by calling: Krite.Worker.start_link(arg)
      # {Krite.Worker, arg},
      # Start to serve requests, typically the last entry
      KriteWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Krite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KriteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
