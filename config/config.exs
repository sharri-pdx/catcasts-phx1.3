# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :catcasts_phx1_3,
  ecto_repos: [CatcastsPhx13.Repo]

# Configures the endpoint
config :catcasts_phx1_3, CatcastsPhx13Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Pw6m6G3c3n73JJ0hd3XPt4ytzk01LpsvfrjEgF/4aeQho5gZhh0IFWlxbslrI/89",
  render_errors: [view: CatcastsPhx13Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CatcastsPhx13.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Google OAuth
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "emails profile plus.me"]}
  ]
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
