defmodule Lix.Reactor.Value do
  alias Lix.Reactor

  def new() do
    Reactor.new(__MODULE__, 0)
  end

  def out_tags(), do: [:value]

  def set(handle, value) do
    Reactor.update(handle, fn _ ->
      value
    end)

    Reactor.broadcast(handle, :value, value)
  end

  def get(handle), do: Reactor.get(handle)

  def add(handle, addition) do
    value =
      Reactor.update(handle, fn value ->
        value + addition
      end)

    Reactor.broadcast(handle, :value, value)
  end
end
