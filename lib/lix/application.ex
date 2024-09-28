defmodule Lix.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Lix.OscClient, []},
      {Registry, keys: :duplicate, name: Lix.OscListeners},
      Lix.Surfaces
    ]

    opts = [strategy: :one_for_one, name: Lix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def on_code_reload() do
    supervisors = [Lix.Surfaces]

    for supervisor <- supervisors do
      for {_id, pid, _type, [module]} <- Supervisor.which_children(supervisor) do
        :sys.suspend(pid)
        :sys.change_code(pid, module, nil, nil)
        :sys.resume(pid)
      end
    end
  end
end
