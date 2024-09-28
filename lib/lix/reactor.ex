defmodule Lix.Reactor do
  alias Lix.Context

  def new(module, initial_state) do
    handle = Context.make_handle()
    Context.set(handle, %{module: module, state: initial_state})
    handle
  end

  def out_tags(handle) do
    Context.get(handle).module.out_tags()
  end

  def get(handle) do
    Context.get(handle).state
  end

  def update(handle, updater) do
    reactor =
      Context.update(handle, fn reactor ->
        %{reactor | state: updater.(reactor.state)}
      end)

    reactor.state
  end

  def broadcast(handle, tag, value) do
    true = tag in out_tags(handle)
    Context.broadcast(handle, tag, value)
  end
end
