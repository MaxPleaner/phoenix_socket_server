# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :server,
  ecto_repos: [Server.Repo]

# Configures the endpoint
config :server, Server.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cNvJn7cJS5bayChCjN0j2fIpILW/7YA1XsJzV6y912m8Bnz14w5kl/n5yModD75R",
  render_errors: [view: Server.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Server.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :addict,
  secret_key: "243262243132246a654259683649777a393034446c5532696138653575",
  extra_validation: fn ({valid, errors}, user_params) -> {valid, errors} end, # define extra validation here
  user_schema: Server.User,
  repo: Server.Repo,
  from_email: "no-reply@example.com", # CHANGE THIS
  generate_csrf_token: (fn -> Phoenix.Controller.get_csrf_token end),
  mail_service: nil,
  post_login: &(Callbacks.PostLogin.run/3),
  post_logout: &(Callbacks.PostLogout.run/3),
  post_register: &(Callbacks.PostRegister.run/3)

config :guardian, Guardian,
  issuer: "MyApp",
  ttl: { 30, :days },
  allowed_drift: 2000,
  secret_key: System.get_env("GUARDIAN_SECRET") || "dev",
  serializer: Server.GuardianSerializer
