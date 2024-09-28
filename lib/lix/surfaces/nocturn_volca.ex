defmodule Lix.Surfaces.NocturnVolca do
  use GenServer
  require Logger
  # alias __MODULE__.Knob
  alias Lix.Reactor
  alias Reactor.Value

  defstruct [
    # :lime
    :volca_index
  ]

  def start_link([]) do
    Logger.debug("Starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(nil) do
    Logger.debug("Initializing #{__MODULE__}")
    {:ok, _} = Lix.OscClient.listen(:osc_message)

    # TODO
    # buttons = for _ <- 0..6, do: Reactor.new()

    # {:ok, volca_index} = Value.start_link()
    # volca_index = Value.add_listener(:value, )
    # Value.on(volca_index, :value, )

    # |> Stream.each(fn value ->
    #   IO.inspect(value, label: "volca_index value")
    # end)
    # |> Stream.run()

    # |> Reactor.on(:value, fn current_index ->
    # Enum.with_index(buttons, fn {button_index, button} ->
    #   button.set.(button_index == current_index)
    # end)
    # end)

    # lime = Reactor.new()

    state = %__MODULE__{
      # volca_index: volca_index
      # lime: lime
    }

    {:ok, state}
  end

  @impl true
  def handle_info({:nocturn_control, control, value}, %{volca_index: volca_index} = state) do
    case control do
      {:knob, 0} ->
        Value.set(volca_index, value)

      _ ->
        nil
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:osc_message, tag, value}, state) do
    # Logger.debug("#{tag}: #{value}")

    case tag do
      <<"mixers/reverb/(gain!", index::binary-size(1), ")/finalValue">> ->
        Logger.debug("Reverb gain, index: #{index}, value: #{value}")

      _ ->
        nil
    end

    {:noreply, state}
  end
end

defmodule Lix.Surfaces.Nocturn.Knob do
  def new() do
    %{}
  end

  def handle() do
  end
end
