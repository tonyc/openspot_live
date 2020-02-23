defmodule OpenspotLiveWeb.Endpoint do
  @session_options [
    store: :cookie,
    key: "_openspot_live_key",
    signing_salt: "bJcjUfFh"
  ]

  use Phoenix.Endpoint, otp_app: :openspot_live

  #socket "/socket", OpenspotLiveWeb.UserSocket,
  #  websocket: true,
  #  longpoll: false


  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [sesison: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :openspot_live,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options
  plug OpenspotLiveWeb.Router
end
