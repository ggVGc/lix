defmodule Lix.Reactor.Counter do
  alias Lix.Reactor.Value

  def new() do
    Value.new()
  end

  def tick(handle) do
    Value.add(handle, 1)
  end

  def get_value(handle), do: Value.get(handle)
end
