
defmodule Morse do

  @moduledoc """

  Transmit a morse message by blinking a Hue light

  """

  @signs %{
    " " => " ",
    "A" => ".-",
    "B" => "-...",
    "C" => "-.-.",
    "D" => "-..",
    "E" => ".",
    "F" => "..-.",
    "G" => "--.",
    "H" => "....",
    "I" => "..",
    "J" => ".---",
    "K" => "-.-.",
    "L" => ".-..",
    "M" => "--",
    "N" => "-.",
    "O" => "---",
    "P" => ".--.",
    "Q" => "--.-",
    "R" => ".-.",
    "S" => "...",
    "T" => "-",
    "U" => "..-",
    "V" => "...-",
    "W" => ".--",
    "X" => "-..-",
    "Y" => "-.--",
    "Z" => "--..",
    "1" => ".----",
    "2" => "..---",
    "3" => "...--",
    "4" => "....-",
    "5" => ".....",
    "6" => "-....",
    "7" => "--...",
    "8" => "---..",
    "9" => "----.",
  }

  @default_unit_duration 750
  @between_letters "/"

  def transmit(message, {_bridge, _light} = blinker, unit_duration \\ @default_unit_duration) do
    message |> sanitize |> translate |> blinks(blinker, unit_duration)
  end

  defp sanitize(message), do: message |> String.upcase |> String.strip

  defp translate(sanitized_message) do
    sanitized_message |> String.codepoints |> Enum.map(fn (letter) -> @signs[letter] end)
  end

  defp blinks(signs, blinker, unit_duration) do
    Enum.each(signs, fn (sign) ->
      blink_letter(sign, blinker, unit_duration)
    end)
  end

  # Blinks a whole letter
  defp blink_letter("", _blinker, unit_duration), do: wait(@between_letters, unit_duration)
  defp blink_letter(<< part :: binary-size(1), parts :: binary >>, blinker, unit_duration) do
    blink_part(part, blinker, unit_duration)
    blink_letter(parts, blinker, unit_duration)
  end

  # Blinks a single dot, dash or space
  defp blink_part(part, blinker, unit_duration) do
    blinker |> on
    wait(part, unit_duration)
    blinker |> off
    wait(unit_duration)
  end

  @transition_time 0

  defp on({bridge, light}),  do: bridge |> Huex.turn_on(light, @transition_time)
  defp off({bridge, light}), do: bridge |> Huex.turn_off(light, @transition_time)

  defp wait(unit_duration),      do: :timer.sleep(unit_duration)
  defp wait(".", unit_duration), do: wait(unit_duration)
  defp wait("-", unit_duration), do: wait(unit_duration * 3)
  defp wait("/", unit_duration), do: wait(unit_duration * 3)
  defp wait(" ", unit_duration), do: wait(unit_duration * 7)

end

#
# Demo
#

bridge_host = System.get_env("HUEX_HOST") || "192.168.1.100"
bridge_user = System.get_env("HUEX_USER") || "huexexamples"

light = 1

bridge = Huex.connect(bridge_host, bridge_user)
blinker = {bridge, light}

Morse.transmit("SOS", blinker)
