# Turns all lights on using a group command

bridge_host = System.get_env("HUEX_HOST") || "192.168.1.100"
bridge_user = System.get_env("HUEX_USER") || "huexexamples"

Huex.connect(bridge_host, bridge_user)
|> Huex.turn_group_on(0)
