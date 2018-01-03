defmodule ColorTest do
  use ExUnit.Case

  alias Huex.Color, as: Color

  test "RGB to HSV" do
    assert {0, 255, 255} == Color.rgb_to_hsv(1, 0, 0)
  end
end
