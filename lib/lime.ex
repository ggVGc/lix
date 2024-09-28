defmodule Lix.Lime do
  require Logger

  defstruct do
    
  end

  def new() do
    %__MODULE__{}
  end

  def handle_message(%__MODULE__{}, tag, value) do
    case tag do
      "mixers/reverb/(gain!9)" <> _ ->
        Logger.info("FaderportSurface: #{tag}: #{value}")

      _ ->
        nil
    end
  end
end
