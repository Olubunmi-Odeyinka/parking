# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :parking,
  ecto_repos: [Parking.Repo]

# Configures the endpoint
config :parking, ParkingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3roWYh2coHZ9WRVamb8rFDKWZE+Xdvo9LDsmb1TdR5tRtpth/cWV9qISS7qfQiWZ",
  render_errors: [view: ParkingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Parking.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# https://elixirschool.com/en/lessons/libraries/guardian/
config :parking, Parking.Guardian,
  issuer: "parking",
  secret_key: "QliPG9VqkdxkX5m18Dhru4yB27bY+lHMo+i4iB7tdmCVD6gKJRRR00jX3fqRWieZ"


config :sendgrid,
  api_key: "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"
