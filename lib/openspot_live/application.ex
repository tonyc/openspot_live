defmodule OpenspotLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias OpenspotLive.Device

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      OpenspotLiveWeb.Endpoint,
      # Starts a worker by calling: OpenspotLive.Worker.start_link(arg)
      # {OpenspotLive.Worker, arg},
      Device.ConnectionSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OpenspotLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OpenspotLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
