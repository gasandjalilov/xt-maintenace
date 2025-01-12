import Config

config :xrpc,
	trace_client: true,
  	trace_server: true,
	handlers: [RPCHandler]

config :tpro_maintanance, Server.Endpoint,
  url: [host: "localhost"],
  server: true,
  http: [port: 5000],
  render_errors: [view: Server.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Server.PubSub,
  live_view: [signing_salt: "random_salt"]


config :phoenix, :json_library, Jason
