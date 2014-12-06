
defmodule ExUnitHueFormatter do
  use GenEvent

  @moduledoc """

  Changes the color of a light based on the outcome of the test suite.

  You can pass in the following additional option to `ExUnit.start`

  - bridge: %Huex.Bridge{...} (required)
  - light: 1 (optional, defaults to 1)

  """

  @color_pass    Huex.Color.rgb(0, 1, 0)
  @color_invalid Huex.Color.rgb(1, 0.75, 0)
  @color_fail    Huex.Color.rgb(0.75, 0, 0)

  # failures_counter, invalids_counter
  defp bulb_color(0, 0), do: @color_pass
  defp bulb_color(0, _), do: @color_invalid
  defp bulb_color(_, _), do: @color_fail

  ## Callbacks

  def init(opts) do
    config = %{
      bridge: opts[:bridge],
      light: opts[:light] || 1,
      failures_counter: 0,
      invalids_counter: 0
    }
    {:ok, config}
  end

  def handle_event({:suite_started, _}, %{bridge: bridge, light: light} = config) do
    bridge |> Huex.turn_off(light)
    {:ok, config}
  end

  def handle_event({:suite_finished, _, _}, %{bridge: bridge, light: light, failures_counter: failures_counter, invalids_counter: invalids_counter}) do
    bridge |> Huex.set_color(light, bulb_color(failures_counter, invalids_counter))
    :remove_handler
  end

  def handle_event({:test_finished, %ExUnit.Test{state: {:invalid, _}}}, config) do
    {:ok, %{config | invalids_counter: config.invalids_counter + 1}}
  end

  def handle_event({:test_finished, %ExUnit.Test{state: {:failed, _}}}, config) do
    {:ok, %{config | failures_counter: config.failures_counter + 1}}
  end

  def handle_event({:case_finished, %ExUnit.TestCase{state: {:failed, _}}}, config) do
    {:ok, %{config | failures_counter: config.failures_counter + 1}}
  end

  def handle_event(_, config) do
    {:ok, config}
  end

end

#
# Demo
#

bridge_host = System.get_env("HUEX_HOST") || "192.168.1.100"
bridge_user = System.get_env("HUEX_USER") || "huexexamples"

ExUnit.start formatters: [ExUnitHueFormatter], bridge: Huex.connect(bridge_host, bridge_user), light: 1

defmodule HueTest do
  use ExUnit.Case

  test "will make the light go green" do
    assert true
  end

  test "will make the light go red" do
    assert false
  end

end
