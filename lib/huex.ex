defmodule Huex do

  @moduledoc """

  ## Elixir client for Philips Hue connected light bulbs.

  Query functions return the response from the API.

  Command functions return a `Bridge` struct in order to be pipeline friendly.

  Read more on the [GitHub page](https://github.com/xavier/huex).

  """

  # Public API

  defmodule Bridge do
    @moduledoc false
    defstruct host: nil, username: nil, status: :ok, error: nil
  end

  @doc """
  Creates a connection with the bridge available on the given host or IP address.
  Requires the connection to be authorized.
  """
  def connect(host, username \\ nil) do
    %Bridge{host: host, username: username}
  end

  @doc """
  Request authorization for the given `username` on the given `bridge`
  Returns an "authorized" connection.

  The authorization process is as follow:

    1. Call `authorize` once, it will return an error
    2. Press the link button on top of your bridge device
    3. Call `authorize` again with the same parameters, it should succeed

  """
  def authorize(bridge, username) do
    payload = %{devicetype: "test user", username: username}
    bridge = bridge |> api_url |> post_json(payload) |> update_bridge(bridge)
    %Bridge{bridge | username: username}
  end

  @doc """
  Fetch all informations available in the `bridge`.
  """
  def info(bridge) do
    bridge |> user_api_url |> get_json |> update_bridge(bridge)
  end

  @doc """
  List the lights conneted to the given `bridge`
  Requires the connection to be authorized.
  """
  def lights(bridge) do
    bridge |> lights_url |> get_json |> update_bridge(bridge)
  end

  @doc """
  Fetch all informations available about the given `light` connected to the `bridge`
  Requires the connection to be authorized.
  """
  def light_info(bridge, light) do
    bridge |> light_url(light) |> get_json |> update_bridge(bridge)
  end

  @doc """
  Turn the given light on
  Requires the connection to be authorized.
  """
  def turn_on(bridge, light) do
    bridge |> set_state(light, %{on: true})
  end

  @doc """
  Turn the given light off
  Requires the connection to be authorized.
  """
  def turn_off(bridge, light) do
    bridge |> set_state(light, %{on: false})
  end

  @doc """
  Sets the color (hue, saturation and brillance) of the given light
  Requires the connection to be authorized.
  """
  def set_color(bridge, light, {h, s, v}) do
    bridge |> set_state(light, %{on: true, hue: h, sat: s, bri: v})
  end

  @doc """
  Sets the color of the given light using Philips' proprietary bi-dimensional color space
  Requires the connection to be authorized.
  """
  def set_color(bridge, light, {x, y}) do
    bridge |> set_state(light, %{on: true, xy: [x, y]})
  end

  @doc """
  Sets the brigthness of the given light (a value between 0 and 1)
  Requires the connection to be authorized.
  """
  def set_brightness(bridge, light, brightness) do
    bridge |> set_state(light, %{on: true, bri: round(brightness * 255.0)})
  end

  @doc """
  Sets the state of the given light. For a list of accepted keys, look at the `state` object in the response of `light_info`
  Requires the connection to be authorized.
  """
  def set_state(bridge, light, new_state) do
    bridge |> light_state_url(light) |> put_json(new_state) |> update_bridge(bridge)
  end

  # Private API

  #
  # Keep track of errors in chainable operations
  #

  # TODO check whether we can possibly receive more than one object in the array
  defp update_bridge([%{"success" => _}], bridge),          do: %Bridge{bridge | status: :ok, error: nil}
  defp update_bridge([%{"error" => _} = response], bridge), do: %Bridge{bridge | status: :error, error: response}

  #
  # URLs
  #


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

end
