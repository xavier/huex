defmodule Huex.Discovery do
  @moduledoc """
  Discover Hue bridges in your network.

  To use this functionality, you must include `nerves_ssdp_client` in your dependencies, as this is not installed by default.
  """

  @doc """
  Attempts to discover any Hue bridges operating on your network. May require multiple attempts to find your bridge.
  """

  @spec discover() :: [String.t()]
  def discover do
    Nerves.SSDPClient.discover()
    |> Enum.filter(fn {_key, map} -> Map.has_key?(map, :"hue-bridgeid") end)
    |> Enum.map(fn {_key, %{host: ip_address}} -> ip_address end)
    |> Enum.uniq()
  end
end
