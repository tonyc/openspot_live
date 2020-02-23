defmodule OpenspotLiveWeb.OpenspotLive do
  use Phoenix.LiveView

  alias OpenspotLiveWeb
  alias Phoenix.Socket.{Broadcast}

  require Logger

  # this is duplicated in lib/openspot_live/device/websocket_worker.ex
  @subscribe_topic "openspot"

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("#{__MODULE__}: mount()")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(OpenspotLive.PubSub, @subscribe_topic)
    end

    socket = socket
             |> assign(:latest_log_text, "")
             |> assign(:latest_log_ts, "")
             |> assign(:call_log, "")
             |> assign(:wifi_rssi, "(Unknown)")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    OpenspotLiveWeb.PageView.render("index.html", assigns)
  end


  @impl true
  def handle_info(%Broadcast{event: "openspot.message", payload: payload}, socket) do
    Logger.debug inspect(payload)

    payload
    |> dispatch(socket)

    #{:noreply, socket}
  end

  defp dispatch(%{"type" => "log", "log" => text, "ts" => ts} = _payload, socket) do
    socket = socket
             |> assign(:latest_log_text, text)
             |> assign(:latest_log_ts, ts)

    {:noreply, socket}
  end

  defp dispatch(%{"type" => "calllog", "dst" => destination, "src" => source} = _payload, socket) do
    text = "#{source} (#{destination})"
    {:noreply, assign(socket, :call_log, text)}
  end

  defp dispatch(%{"type" => "wifirssi", "rssi" => text} = _payload, socket) do
    {:noreply, assign(socket, :wifi_rssi, text)}
  end

  defp dispatch(%{"type" => "status"} = _payload, socket) do
    {:noreply, socket}
  end

  defp dispatch(%{"type" => unknown_type} = payload, socket) do
    Logger.info("*** UNKNOWN MESSAGE TYPE:: #{unknown_type}")
    Logger.info("   #{inspect payload}")
    {:noreply, socket}
  end
end
