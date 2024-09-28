defmodule Lix.Surfaces do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    children = [
      {Registry, keys: :duplicate, name: Lix.DeviceListeners},
      Lix.Surfaces.Faderport,
      Lix.Devices.NocturnDevice,
      {Lix.Surfaces.NocturnVolca, []}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 100, max_seconds: 5)
  end
end
