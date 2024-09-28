defmodule Lix.ReactorTest do
  use ExUnit.Case
  alias Lix.Reactor.{Counter, Value}
  alias Lix.Context
  doctest Lix

  test "Counter counts" do
    counter = Counter.new()
    assert Counter.get_value(counter) == 0

    handler = fn value ->
      assert value == 1
      Process.put(:test_called_dispatcher, true)
    end

    Context.subscribe(counter, :value, handler)
    Counter.tick(counter)
    assert Counter.get_value(counter) == 1
    assert Process.get(:test_called_dispatcher) == true
  end

  test "can connect two reactors" do
    counter = Counter.new()
    value = Value.new()
    assert Counter.get_value(counter) == 0
    assert Value.get(value) == 0

    Context.subscribe(counter, :value, {value, :set})
    Counter.tick(counter)

    assert Value.get(value) == 1
  end
end
