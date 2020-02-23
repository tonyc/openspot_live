defmodule OpenspotLive.Device.WebsocketWorker do
  #require Logger

  alias OpenspotLiveWeb.{Endpoint}

  # this is duplicated in lib/openspot_live_web/openspot_live.ex
  @broadcast_topic "openspot"
  @broadcast_message "openspot.message"

  use WebSockex

  @hostname "openspot.local"
  @default_password "openspot"
  @json_headers [
    {"Accept", "application/json"},
    {"Content-Type", "application/json"},
    {"Connection", "keep-alive"}
  ]

  def start_link(_args \\ [], state \\ %{}) do
    #Logger.info("#{__MODULE__}: start_link()")
    {:ok, jwt} = authenticate()

    IO.puts("JWT: #{jwt}")
    url = "ws://" <> @hostname <> "/" <> jwt

    WebSockex.start_link(url, __MODULE__, state,
      extra_headers: [{"Sec-WebSocket-Protocol", "openspot2"}],
      name: __MODULE__
    )
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    #Logger.debug(msg)

    msg
    |> Jason.decode!()
    |> dispatch_msg

    {:ok, state}
  end

  @impl true
  def handle_frame({_type, _msg}, state) do
    #Logger.debug("handle_frame: {#{inspect(type)}, #{inspect(msg)}}")
    # IO.puts("Received type: #{inspect(type)}, msg: #{inspect(msg)}")
    {:ok, state}
  end

  def dispatch_msg(msg) do
    msg |> broadcast!
  end

  # def dispatch_msg(%{"type" => "status", "status" => status} = _msg) do
  #  DefaultSeries.from_map(%{
  #    cn_rx_bytes: status["cn_rx_bytes"],
  #    cn_tx_bytes: status["cn_tx_bytes"],
  #    gw_rx_bytes: status["gw_rx_bytes"],
  #    gw_tx_bytes: status["gw_tx_bytes"],
  #    rx_bytes: status["rx_bytes"],
  #    tx_bytes: status["tx_bytes"]
  #  })
  # end

  #def dispatch_msg(_msg) do
  #  #msg |> broadcast!()
  #end

  def authenticate(password \\ @default_password) do
    {:ok, response} = HTTPoison.get(api_url("gettok"))
    {:ok, %{"token" => token}} = Jason.decode(response.body)

    digest = digest_password(password, token)

    login_payload =
      Jason.encode!(%{
        token: token,
        digest: digest
      })

    {:ok, response} = HTTPoison.post(api_url("login"), login_payload, @json_headers)

    {:ok, %{"jwt" => jwt}} = Jason.decode(response.body)

    IO.puts("Got JWT: #{jwt}")

    {:ok, jwt}
  end

  defp api_url(path), do: @hostname <> "/" <> path

  def digest_password(password, token) do
    :crypto.hash(:sha256, token <> password) |> Base.encode16() |> String.downcase()
  end

  defp broadcast!(payload) do
     Endpoint.broadcast(@broadcast_topic, @broadcast_message, payload)
  end
end
