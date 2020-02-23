defmodule OpenspotLive.Device.ConnectionSupervisor do
  use Supervisor

  require Logger

  alias OpenspotLive.Device.{WebsocketWorker}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      WebsocketWorker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
