# defmodule Lix.Connections do
# end

defmodule Lix.Connections.Builder do
  alias Lix.Context
  alias Lix.Reactor.Value
  require Logger

  defmodule Source do
    defstruct [:handle, :out_tag]
  end

  def from(handle) when is_integer(handle) do
    %Source{handle: handle, out_tag: nil}
  end

  def from(%Source{handle: handle}, out_tag) do
    %Source{handle: handle, out_tag: out_tag}
  end

  def from(handle, out_tag) when is_integer(handle) do
    %Source{handle: handle, out_tag: out_tag}
  end

  def to(%Source{handle: handle, out_tag: out_tag}, to_handle, to_tag) when not is_nil(out_tag) do
    Context.subscribe(handle, out_tag, {to_handle, to_tag})
    %Source{handle: to_handle, out_tag: nil}
  end

  def from_to(handle, out_tag, to_handle, to_tag) when is_integer(handle) do
    Context.subscribe(handle, out_tag, {to_handle, to_tag})
    to_handle
  end

  def from_to(%Source{handle: handle}, out_tag, to_handle, to_tag) do
    Context.subscribe(handle, out_tag, {to_handle, to_tag})
    to_handle
  end

  def map(%Source{handle: from_handle, out_tag: out_tag}, handler)
      when is_function(handler) and not is_nil(out_tag) do
    result = Value.new()

    Context.subscribe(from_handle, out_tag, fn value ->
      Value.set(result, handler.(value))
    end)

    %Source{handle: result, out_tag: :value}
  end

  def map_from(handle, out_tag, handler) when is_integer(handle) and is_function(handler) do
    __MODULE__.map(%Source{handle: handle, out_tag: out_tag}, handler)
  end

  def map_from(%Source{handle: handle}, out_tag, handler) when is_function(handler) do
    Context.subscribe(handle, out_tag, handler)
  end
end
