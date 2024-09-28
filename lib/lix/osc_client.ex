defmodule Lix.OscClient do
  use GenServer
  require Logger

  alias OSCx.Message

  @send_port 9999
  @recv_port 7777
  @topic :osc_broadcast

  def start_link([]) do
    Logger.debug("Starting")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    {:ok, socket} = :gen_udp.open(@recv_port, [:binary, active: true])
    {:ok, %{socket: socket}}
  end

  def send_message(tag, value) do
    GenServer.cast(__MODULE__, {:send_message, tag, value})
  end

  def listen(message_name) do
    Registry.register(Lix.OscListeners, @topic, message_name)
  end

  @impl true
  def handle_cast({:send_message, tag, value}, %{socket: socket} = state) do
    Logger.info("Sending message")
    message = %Message{address: tag, arguments: [value]}
    :ok = :gen_udp.send(socket, {127, 0, 0, 1}, @send_port, OSCx.encode(message))
    {:noreply, state}
  end

  @impl true
  def handle_info({:udp, _socket, _address, _port, data}, state) do
    %Message{address: tag, arguments: [value]} = OSCx.decode(data)

    Registry.dispatch(Lix.OscListeners, @topic, fn listeners ->
      :ok =
        listeners
        |> Task.async_stream(fn {pid, message_name} ->
          send(pid, {message_name, tag, value})
        end)
        |> Stream.run()
    end)

    {:noreply, state}
  end
end
