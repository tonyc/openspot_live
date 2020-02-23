defmodule OpenspotLiveWeb.PageController do
  use OpenspotLiveWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, OpenspotLiveWeb.OpenspotLive)
  end
end
