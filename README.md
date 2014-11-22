# Huex

Elixir client for Philips Hue connected light bulbs.

## Installation

Add Huex as a dependency in your `mix.exs` file.

```elixir
def deps do
  [ { :huex, "~> 0.1" } ]
end
```

After you are done, run `mix deps.get` in your shell to fetch and compile Huex.

## Usage

### First Connection

```elixir
# When connecting to the bridge API for the very first
# we need to request an authorization for a new user (here named "huex")

bridge = Huex.connect("192.168.1.100") |> Huex.authorize("huexexamples")

# As requested, press the link button on the bridge to authorize this new user
# then request authorization again

Huex.authorize(bridge, "huexexamples")

# We can now query the Hue bridge about the connected lights

IO.inspect Huex.info(bridge)
# %{"config" => %{"UTC" => "1970-01-01T03:00:40", "dhcp" => true,
#    "gateway" => "192.168.1.1", "ipaddress" => "192.168.1.100",
#    ...
#   "schedules" => %{}}
```

### Subsequent Connections

Once a user has been authorized with the Bridge, there's no need to perform
the authorization process, you can connect right away.

```elixir

bridge = Huex.connect("192.168.1.100", "huexexamples")

IO.inspect Huex.lights(bridge)
# %{"1" => %{"name" => "Lobby"}, "2" => %{"name" => "Living Room"},
#    "3" => %{"name" => "Bedroom"}}

IO.inspect Huex.light_info(bridge, 1)
# %{"modelid" => "LCT001", "name" => "Lobby",
#   ...
#   "swversion" => "66009663", "type" => "Extended color light"}
```

### Lights State Management

All update functions are chainable.

```elixir
# And we can of course, change the state of the connected lights
bridge
|> Huex.turn_off(1)                                  # Turn off light 1
|> Huex.turn_on(2)                                   # Turn off light 2
|> Huex.set_color(2, {10000, 255, 255})              # HSV
|> Huex.set_color(2, {0.167, 0.04})                  # XY
|> Huex.set_color(2, Huex.Color.rgb(1, 0.75, 0.25))  # RGB (see limitations)
|> Huex.set_brightness(2, 0.75)                      # Brightness at 75%

```

### Examples

Look into the `examples` directory for more advanced usage examples.

## Limitations

Colorspace conversion from RGB to XY currently feels a little fishy: I can't seem to get bright green or red using the given formula.

## To Do

[ ] Reliable color conversion from RGB
[ ] Hex package
