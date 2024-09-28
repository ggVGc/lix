import Config

config :logger, :console,
  format: "[$level] $metadata| $message\n",
  metadata: [:error_code, :module]

if Mix.env() == :dev do
  config :exsync,
    reload_timeout: 75,
    reload_callback: {Lix.Application, :on_code_reload, []}
end
