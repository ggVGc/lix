defmodule Lix.Surfaces.Faderport do
  use GenServer
  require Logger
  alias Lix.MIDI

  def start_link([]) do
    Logger.debug("Starting FaderportSurface")
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(nil) do
    Logger.info("Initializing #{__MODULE__}")
    {:ok, _} = Lix.OscClient.listen(:osc_message)

    case Midiex.ports(~r"PreSonus FP8", :input) do
      [in_port] ->
        Midiex.subscribe(in_port)

        [out_port] = Midiex.ports(~r"PreSonus FP8", :output)
        output = Midiex.open(out_port)

        {:ok, %{output: output}}

      [] ->
        Logger.error("Initialization failed. No ports found.")
        {:ok, nil}
    end
  end

  @impl true
  def handle_info({:osc_message, _tag, _value}, state) do
    # Logger.info("#{tag}: #{value}")
    {:noreply, state}
  end

  @impl true
  def handle_info(%Midiex.MidiMessage{} = msg, %{output: output} = state) do
    IO.inspect(msg, label: "msg")
    _parsed = MIDI.parse_status(List.first(msg.data)) |> IO.inspect(label: "parsed")

    [tag, _, value] = msg.data
    channel = Bitwise.band(0x0F, tag)
    tag = Bitwise.band(0xF0, tag)
    IO.inspect({tag, channel}, label: "tag, channel")

    Midiex.send_msg(output, Midiex.Message.note_on(70, value))

    {:noreply, state}
  end

  # @impl true
  # def code_change(old, state, extra) do
  #   Logger.info(
  #     "Code change, state: #{inspect(state)}, old: #{inspect(old)}, extra: #{inspect(extra)}"
  #   )

  #   {:ok, state}
  # end
end
