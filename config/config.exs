# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config
# Configures the endpoint
config :openspot_live, OpenspotLiveWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vTZwf6pddEXWYeugZi8GuZ3GSJ7IBJH8DM8bmiqrC194J5EskmWbjzWvMa6YnUcH",
  render_errors: [view: OpenspotLiveWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OpenspotLive.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "some_signing_salt"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
