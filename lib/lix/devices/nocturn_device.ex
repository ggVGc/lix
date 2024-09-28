defmodule Lix.Devices.NocturnDevice do
  use GenServer
  require Logger
  alias Lix.MIDI

  defmodule MidiMapping do
    @cc_mappings Map.new(65..(65 + 8), &{:knob, &1 - 65})
    def get(:cc, number, value) do
      with {:ok, control} <- Map.fetch(@cc_mappings, number) do
        {:ok, {control, value}}
      end
    end

    def get(_tag, _number, _value), do: :error
  end

  def start_link([]) do
    Logger.debug("Starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(nil) do
    Logger.info("Initializing #{__MODULE__}")

    state = %{output: open_midi_ports()}

    {:ok, state}
  end

  defp open_midi_ports() do
    case Midiex.ports(~r"Nocturn", :input) do
      [in_port] ->
        [out_port] = Midiex.ports(~r"Nocturn", :output)

        Midiex.subscribe(in_port)
        Midiex.open(out_port)

      [] ->
        Logger.error("Initialization failed. No ports found.")
        nil
    end
  end

  @impl true
  def handle_info(%Midiex.MidiMessage{} = msg, %{handler: handler} = state) do
    [status, value1, value2] = msg.data

    {tag, _chanel} = MIDI.parse_status(status)
    {:ok, {control, value}} = MidiMapping.get(tag, value1, value2)
    handler.(control, value)

    {:noreply, state}
  end

  @impl true
  def code_change(old, state, extra) do
    Logger.info(
      "Code change, state: #{inspect(state)}, old: #{inspect(old)}, extra: #{inspect(extra)}"
    )

    {:ok, state}
  end
end
