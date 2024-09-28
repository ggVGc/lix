defmodule Lix.MIDI do
  @status_tags %{
    0x8 => :note_off,
    0x9 => :note_on,
    0xB => :cc,
    0xE => :pitchbend
  }

  def parse_status(status) do
    <<tag::4, channel::4>> = <<status::8>>

    if tag = Map.get(@status_tags, tag) do
      {tag, channel}
    end
  end
end
