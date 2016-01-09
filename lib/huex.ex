defmodule Huex do

  @moduledoc """

  ## Elixir client for Philips Hue connected light bulbs.

  Query functions return the response from the API.

  Command functions return a `Bridge` struct in order to be pipeline friendly.

  Read more on the [GitHub page](https://github.com/xavier/huex).

  """


  @typedoc ""
  @type bridge :: Bridge.t

  @typedoc """
  Light identifier can be either a numberic or a binary (e.g. "1")
  """
  @type light :: non_neg_integer | binary

  @typedoc """
  Group identifier can be either a numberic or a binary (e.g. "1"). Special group 0 always contains all the lights.
  """
  @type group :: non_neg_integer | binary

  @typedoc """
  Tuple containing respectively the hue (0-65535), staturation (0-255) and value/brillance (0-255) components
  """
  @type hsv_color :: {non_neg_integer, non_neg_integer, non_neg_integer}

  @typedoc """
  Tuple containing the x and y component of the color
  """
  @type xy_color  :: {float, float}

  @typedoc """
  Possible status of a `Bridge`
  """
  @type status  :: nil | :ok | :error

  # Public API

  defmodule Bridge do
    @moduledoc """

    Stores the state of the connection with the bridge device

    * `host`     - IP address or hostname of the bridge device
    * `username` - username used to issue API calls to the bridge device
    * `status`   - `:ok` or `:error`
    * `error`    - error message

    """
    defstruct host: nil, username: nil, status: :ok, error: nil

    @type t :: %__MODULE__{
                 host: binary,
                 username: binary,
                 status: Huex.status,
                 error: nil | binary}
  end

  @doc """
  Creates a connection with the bridge available on the given host or IP address.
  Requires the connection to be authorized.
  """

  @spec connect(binary, binary) :: bridge
  def connect(host, username \\ nil) do
    %Bridge{host: host, username: username}
  end

  @doc """
  Requests authorization for the given `username` on the given `bridge`.
  Returns an "authorized" connection.

  The authorization process is as follow:

    1. Call `authorize` once, it will return an error
    2. Press the link button on top of your bridge device
    3. Call `authorize` again with the same parameters, it should succeed

  """
  @spec authorize(bridge, binary) :: bridge
  def authorize(bridge, username) do
    payload = %{devicetype: "test user", username: username}
    bridge = bridge |> api_url |> post_json(payload) |> update_bridge(bridge)
    %Bridge{bridge | username: username}
  end

  @doc """
  Fetches all informations available in the `bridge`.
  """
  @spec info(bridge) :: Map.t
  def info(bridge) do
    bridge |> user_api_url |> get_json
  end

  @doc """
  Lists the lights connected to the given `bridge`.
  Requires the connection to be authorized.
  """
  @spec lights(bridge) :: Map.t
  def lights(bridge) do
    bridge |> lights_url |> get_json
  end

  @doc """
  Fetches all informations available about the given `light` connected to the `bridge`.
  Requires the connection to be authorized.
  """
  @spec light_info(bridge, light) :: Map.t
  def light_info(bridge, light) do
    bridge |> light_url(light) |> get_json
  end

  @doc """
  Turns the given light on.
  Requires the connection to be authorized.
  """
  @spec turn_on(bridge, light) :: bridge
  def turn_on(bridge, light) do
    bridge |> set_state(light, %{on: true})
  end

  @doc """
  Turns the given light on using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec turn_on(bridge, light, non_neg_integer) :: bridge
  def turn_on(bridge, light, transition_time_ms) do
    bridge |> set_state(light, %{on: true, transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Turns the given light off.
  Requires the connection to be authorized.
  """
  @spec turn_off(bridge, light) :: bridge
  def turn_off(bridge, light) do
    bridge |> set_state(light, %{on: false})
  end

  @doc """
  Turns the given light off using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec turn_off(bridge, light, non_neg_integer) :: bridge
  def turn_off(bridge, light, transition_time_ms) do
    bridge |> set_state(light, %{on: false, transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the color (hue, saturation and brillance) of the given light.
  Requires the connection to be authorized.
  """
  @spec set_color(bridge, light, hsv_color) :: bridge
  def set_color(bridge, light, {h, s, v}) do
    bridge |> set_state(light, %{on: true, hue: h, sat: s, bri: v})
  end

  @doc """
  Sets the color of the given light using Philips' proprietary bi-dimensional color space.
  Requires the connection to be authorized.
  """
  @spec set_color(bridge, light, xy_color) :: bridge
  def set_color(bridge, light, {x, y}) do
    bridge |> set_state(light, %{on: true, xy: [x, y]})
  end

  @doc """
  Sets the color (hue, saturation and brillance) of the given light using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec set_color(bridge, light, hsv_color, non_neg_integer) :: bridge
  def set_color(bridge, light, {h, s, v}, transition_time_ms) do
    bridge |> set_state(light, %{on: true, hue: h, sat: s, bri: v, transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the color of the given light using Philips' proprietary bi-dimensional color space using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec set_color(bridge, light, xy_color, non_neg_integer) :: bridge
  def set_color(bridge, light, {x, y}, transition_time_ms) do
    bridge |> set_state(light, %{on: true, xy: [x, y], transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the brigthness of the given light (a value between 0 and 1).
  Requires the connection to be authorized.
  """
  @spec set_brightness(bridge, light, float) :: bridge
  def set_brightness(bridge, light, brightness) do
    bridge |> set_state(light, %{on: true, bri: round(brightness * 255.0)})
  end

  @doc """
  Sets the brigthness of the given light (a value between 0 and 1) using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec set_brightness(bridge, light, float, non_neg_integer) :: bridge
  def set_brightness(bridge, light, brightness, transition_time_ms) do
    bridge |> set_state(light, %{on: true, bri: round(brightness * 255.0), transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the state of the given light. For a list of accepted keys, look at the `state` object in the response of `light_info`
  Requires the connection to be authorized.
  """
  @spec set_state(bridge, light, Map.t) :: bridge
  def set_state(bridge, light, new_state) do
    bridge |> light_state_url(light) |> put_json(new_state) |> update_bridge(bridge)
  end

  @doc """
  Lists the light groups configured for the given `bridge`.
  Requires the connection to be authorized.
  """
  @spec groups(bridge) :: Map.t
  def groups(bridge) do
    bridge |> groups_url |> get_json
  end

  @doc """
  Fetches all informations available about the given `group` connected to the `bridge`.
  Requires the connection to be authorized.
  """
  @spec group_info(bridge, group) :: Map.t
  def group_info(bridge, group) do
    bridge |> group_url(group) |> get_json
  end

  @doc """
  Turns the given group on.
  Requires the connection to be authorized.
  """
  @spec turn_group_on(bridge, group) :: bridge
  def turn_group_on(bridge, group) do
    bridge |> set_group_state(group, %{on: true})
  end

  @doc """
  Turns the given group on using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec turn_group_on(bridge, group, non_neg_integer) :: bridge
  def turn_group_on(bridge, group, transition_time_ms) do
    bridge |> set_group_state(group, %{on: true, transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Turns the given group off.
  Requires the connection to be authorized.
  """
  @spec turn_group_off(bridge, group) :: bridge
  def turn_group_off(bridge, group) do
    bridge |> set_group_state(group, %{on: false})
  end

  @doc """
  Turns the given group off using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec turn_group_off(bridge, group, non_neg_integer) :: bridge
  def turn_group_off(bridge, group, transition_time_ms) do
    bridge |> set_group_state(group, %{on: false, transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the color (hue, saturation and brillance) of the given group.
  Requires the connection to be authorized.
  """
  @spec set_group_color(bridge, group, hsv_color) :: bridge
  def set_group_color(bridge, group, {h, s, v}) do
    bridge |> set_group_state(group, %{on: true, hue: h, sat: s, bri: v})
  end

  @doc """
  Sets the color of the given group using Philips' proprietary bi-dimensional color space.
  Requires the connection to be authorized.
  """
  @spec set_group_color(bridge, group, xy_color) :: bridge
  def set_group_color(bridge, group, {x, y}) do
    bridge |> set_group_state(group, %{on: true, xy: [x, y]})
  end

  @doc """
  Sets the color (hue, saturation and brillance) of the given group using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec set_group_color(bridge, group, hsv_color, non_neg_integer) :: bridge
  def set_group_color(bridge, group, {h, s, v}, transition_time_ms) do
    bridge |> set_group_state(group, %{on: true, hue: h, sat: s, bri: v, transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the color of the given group using Philips' proprietary bi-dimensional color space using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec set_group_color(bridge, group, xy_color, non_neg_integer) :: bridge
  def set_group_color(bridge, group, {x, y}, transition_time_ms) do
    bridge |> set_group_state(group, %{on: true, xy: [x, y], transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the brigthness of the given group (a value between 0 and 1).
  Requires the connection to be authorized.
  """
  @spec set_group_brightness(bridge, group, float) :: bridge
  def set_group_brightness(bridge, group, brightness) do
    bridge |> set_group_state(group, %{on: true, bri: round(brightness * 255.0)})
  end

  @doc """
  Sets the brigthness of the given group (a value between 0 and 1) using the given transition time (in ms).
  Requires the connection to be authorized.
  """
  @spec set_group_brightness(bridge, group, float, non_neg_integer) :: bridge
  def set_group_brightness(bridge, group, brightness, transition_time_ms) do
    bridge |> set_group_state(group, %{on: true, bri: round(brightness * 255.0), transitiontime: transition_time(transition_time_ms)})
  end

  @doc """
  Sets the state of the given group. For a list of accepted keys, look at the `state` object in the response of `group_info`
  Requires the connection to be authorized.
  """
  @spec set_group_state(bridge, group, Map.t) :: bridge
  def set_group_state(bridge, group, new_state) do
    bridge |> group_state_url(group) |> put_json(new_state) |> update_bridge(bridge)
  end


  # Private API

  #
  # Keep track of errors in chainable operations
  #

  defp update_bridge(response, bridge) do
    case Enum.find(response, fn (hash) -> hash["error"] end) do
      nil -> %Bridge{bridge | status: :ok, error: nil}
      _   -> %Bridge{bridge | status: :error, error: response}
    end
  end

  #
  # URLs
  #

  defp group_state_url(bridge, group), do: group_url(bridge, group) <> "/action"
  defp group_url(bridge, group), do: groups_url(bridge) <> "/#{group}"
  defp groups_url(bridge), do: user_api_url(bridge, "groups")

  defp light_state_url(bridge, light), do: light_url(bridge, light) <> "/state"
  defp light_url(bridge, light), do: lights_url(bridge) <> "/#{light}"
  defp lights_url(bridge), do: user_api_url(bridge, "lights")

  defp user_api_url(bridge, relative_path), do: user_api_url(bridge) <> "/#{relative_path}"
  defp user_api_url(%Bridge{username: username} = bridge), do: api_url(bridge, username)

  defp api_url(bridge, relative_path), do: api_url(bridge) <> "/#{relative_path}"
  defp api_url(%Bridge{host: host}),   do: "http://#{host}/api"

  #
  # HTTP request / response helpers
  #

  defp get_json(url) do
    url |> HTTPoison.get |> handle_response
  end

  defp post_json(url, data) do
    json = encode_request(data)
    url |> HTTPoison.post(json) |> handle_response
  end

  defp put_json(url, data) do
    json = encode_request(data)
    url |> HTTPoison.put(json) |> handle_response
  end

  defp encode_request(data) do
    {:ok, json} = JSON.encode(data)
    json
  end

  # TODO FIXME figure out why HTTPoison always treat the response as an error
  defp handle_response({:ok, response}), do: decode_response_body(response.body)
  defp handle_response({:error, %HTTPoison.Error{id: nil, reason: {:closed, body}}}), do: decode_response_body(body)

  defp decode_response_body(body) do
    {:ok, object} = JSON.decode(body)
    object
  end

  #
  # Miscellaneous helpers
  #

  defp transition_time(ms), do: div(ms, 100)

end
