# Prints some information about the lights connected to the bridge

bridge_host = System.get_env("HUEX_HOST") || "192.168.1.100"
bridge_user = System.get_env("HUEX_USER") || "huexexamples"

info   = Huex.connect(bridge_host, bridge_user) |> Huex.info
lights = info["lights"]

lights |> Enum.each(fn ({light_id, light_info}) ->

  name   = light_info["name"]
  model  = light_info["modelid"]

  state  = light_info["state"]
  on_off = if state["on"], do: "ON", else: "off"

  IO.puts "Light ##{light_id} '#{name}' (#{model}) is #{on_off}"

end)