IO.puts("Discovering Hue bridges using SSDP...")

Huex.Discovery.discover()
|> Enum.join("\n")
|> IO.puts()
