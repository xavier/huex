# Huex

Elixir client for Philips Hue connected light bulbs.

## Installation

Add Huex as a dependency in your `mix.exs` file.

```elixir
def deps do
  [ { :huex, "~> 0.6" } ]
end
```

After you are done, run `mix deps.get` in your shell to fetch and compile Huex.

## Usage

### First Connection

In order to issue queries and commands to the bridge, we need to request an authorization for a so-called `devicetype` (see [Hue Configuration API](http://www.developers.meethue.com/documentation/configuration-api)) which is a string formatted as such: `my-app#my-device`.

**Before requesting the authorization**: you must **press the link button** on your bridge device to start a 30 second window during which you may request an authorization as follow:

```elixir
bridge = Huex.connect("192.168.1.100") |> Huex.authorize("my-app#my-device")

# A random username is now set
IO.puts bridge.username
# YApVhLTwWUTlGJDo...

# The bridge connection is now ready for use
IO.inspect Huex.info(bridge)
# %{"config" => ...}

```

### Subsequent Connections

Once a `devicetype` has been authorized with the bridge, there's no need to perform the authorization process again. In other words, you must **store the generated username** received set by `authorize/2`. With the username at hand, you can connect right away:

```elixir
bridge = Huex.connect("192.168.1.100", "YApVhLTwWUTlGJDo...")

IO.inspect Huex.info(bridge)
# %{"config" => ...}

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

## Contributors

In order of appearance:

* Xavier Defrang ([xavier](https://github.com/xavier))
* Brandon Hays ([tehviking](https://github.com/tehviking))
* Brian Davis ([mrbriandavis](https://github.com/mrbriandavis))
* Pete Kazmier ([pkazmier](https://github.com/pkazmier))

## License

Copyright 2014 Xavier Defrang

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
