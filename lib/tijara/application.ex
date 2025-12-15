defmodule Tijara.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TijaraWeb.Telemetry,
      Tijara.Repo,
      {DNSCluster, query: Application.get_env(:tijara, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tijara.PubSub},
      # Start a worker by calling: Tijara.Worker.start_link(arg)
      # {Tijara.Worker, arg},
      # Start to serve requests, typically the last entry
      TijaraWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :tijara]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tijara.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TijaraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
