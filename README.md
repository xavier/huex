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

When connecting to the bridge API for the very first time, we need to request an
authorization for a new user (here named "huexexamples")

```elixir
bridge = Huex.connect("192.168.1.100") |> Huex.authorize("huexexamples")

# As requested, press the link button on the bridge to authorize this new user
# then request authorization again

bridge = Huex.authorize(bridge, "huexexamples")

```

### Subsequent Connections

Once a user has been authorized with the bridge, there's no need to perform
the authorization process, you can connect right away.

```elixir
bridge = Huex.connect("192.168.1.100", "huexexamples")
```

### Queries

Query functions return the message received from the bridge API.

```elixir
IO.inspect Huex.info(bridge)
# %{"config" => %{"UTC" => "1970-01-01T03:00:40", "dhcp" => true,
#   "gateway" => "192.168.1.1", "ipaddress" => "192.168.1.100",
#    ...
#   "schedules" => %{}}

IO.inspect Huex.lights(bridge)
# %{"1" => %{"name" => "Lobby"}, "2" => %{"name" => "Living Room"},
#    "3" => %{"name" => "Bedroom"}}

IO.inspect Huex.light_info(bridge, 1)
# %{"modelid" => "LCT001", "name" => "Lobby",
#   ...
#   "swversion" => "66009663", "type" => "Extended color light"}
```

### Commands

Command functions return a `Huex.Bridge` struct and are thus chainable.

```elixir
bridge
|> Huex.turn_off(1)                                  # Turn off light 1
|> Huex.turn_on(2)                                   # Turn on light 2
|> Huex.set_color(2, {10000, 255, 255})              # HSV
|> Huex.set_color(2, {0.167, 0.04})                  # XY
|> Huex.set_color(2, Huex.Color.rgb(1, 0.75, 0.25))  # RGB (see limitations)
|> Huex.set_brightness(2, 0.75)                      # Brightness at 75%
```

#### Error Handling

For error handling, the `Huex.Bridge` struct has a `status` attribute which is either set to `:ok` or `:error` by command functions.

When an error occured, the complete error response is stored in the `error` attribute of the `Huex.Bridge` struct.

### Examples

Look into the `examples` directory for more advanced usage examples.

## Current Limitations

Color space conversion from RGB to XY currently feels a little fishy: I can't seem to get bright green or red using the given formula.

## To Do

- [ ] Reliable color conversion from RGB
- [ ] Hex package

## License

Copyright 2014 Xavier Defrang

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.