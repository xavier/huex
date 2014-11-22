
# Prints some information about the lights connected to the bridge

info   = Huex.connect("192.168.1.100", "huexexamples") |> Huex.info
lights = info["lights"]

lights |> Enum.each(fn ({light_id, light_info}) ->

  name   = light_info["name"]
  model  = light_info["modelid"]

  state  = light_info["state"]
  on_off = if state["on"], do: "ON", else: "off"

  IO.puts "Light ##{light_id} '#{name}' (#{model}) is #{on_off}"

end)