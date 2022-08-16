import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_stacks, ExStacksWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Qj1hOcT+w5GcivNUIszTYNCn7CqR/Za6DVrXJBxM9zEOBbL6YsMK6SJEEInmisO5",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
