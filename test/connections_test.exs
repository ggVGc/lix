defmodule Lix.ConnectionsTest do
  use ExUnit.Case
  import Lix.Connections.Builder

  alias Lix.Reactor.{Counter, Value}

  test "chaining" do
    counter = Counter.new()
    value = Value.new()

    final_value =
      counter
      |> from_to(:value, value, :set)
      |> map_from(:value, &IO.inspect(&1, label: "value"))
      |> map(&IO.inspect(&1, label: "value again"))

    final_value |> map(fn _ -> IO.puts("UYEOOO") end)
    final_value |> map(fn _ -> IO.puts("Also Yeo") end)

    Counter.tick(counter)
    Counter.tick(counter)
  end
end
