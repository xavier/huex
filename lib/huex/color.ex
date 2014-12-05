defmodule Huex.Color do

  @typedoc """
  Tuple containing respectively the red, greend and blue components of a color, each between 0 and 1
  """
  @type rgb_color :: {float, float, float}

  @doc """

  Converts from normalized RGB (each component must be in the 0.0 to 1.0 range) Philips Hue XY colorspace

  """

  #
  # From the Hue SDK documentation:
  #
  # For the hue bulb the corners of the triangle are:
  # Red: 0.675, 0.322
  # Green: 0.4091, 0.518
  # Blue: 0.167, 0.04
  # (...)
  #
  # Color to xy
  #
  # We start with the color to xy conversion, which we will do in a couple of steps:
  #
  # 1. Get the RGB values from your color object and convert them to be between 0 and 1.
  # So the RGB color (255, 0, 100) becomes (1.0, 0.0, 0.39)
  #
  # 2. Apply a gamma correction to the RGB values, which makes the color more vivid and more the like the color displayed on the screen of your device.
  # This gamma correction is also applied to the screen of your computer or phone, thus we need this to create the same color on the light as on screen.
  # This is done by the following formulas:
  # float red   = (red   > 0.04045f) ? pow((red   + 0.055f) / (1.0f + 0.055f), 2.4f) : (red   / 12.92f);
  # float green = (green > 0.04045f) ? pow((green + 0.055f) / (1.0f + 0.055f), 2.4f) : (green / 12.92f);
  # float blue  = (blue  > 0.04045f) ? pow((blue  + 0.055f) / (1.0f + 0.055f), 2.4f) : (blue  / 12.92f);
  #
  # 3. Convert the RGB values to XYZ using the Wide RGB D65 conversion formula
  # The formulas used:
  #
  #     float X = red * 0.649926f + green * 0.103455f + blue * 0.197109f;
  #
  #     float Y = red * 0.234327f + green * 0.743075f + blue * 0.022598f;
  #
  #     float Z = red * 0.0000000f + green * 0.053077f + blue * 1.035763f;
  #
  #
  # 4. Calculate the xy values from the XYZ values
  #
  #     float x = X / (X + Y + Z);
  #
  #     float y = Y / (X + Y + Z);
  #

  @spec rgb(float, float, float) :: Huex.xy_color
  def rgb(r, g, b), do: rgb_to_xy({r, g, b})

  @spec rgb(rgb_color) :: Huex.xy_color
  def rgb(rgb),     do: rgb_to_xy(rgb)

  def rgb_to_xy(r, g, b),  do: rgb_to_xy({r, g, b})
  def rgb_to_xy(rgb_tuple) do
    rgb_tuple |> correct_gamma |> rgb_to_xyz |> xyz_to_xy
  end

  defp correct_gamma({r, g, b}) do
    {
      correct_gamma(r),
      correct_gamma(g),
      correct_gamma(b)
    }
  end

  # Gamma correction for a single RGB component
  defp correct_gamma(c) when c > 0.04045, do: :math.pow((c + 0.055) / (1.0 + 0.055), 2.4)
  defp correct_gamma(c), do: c / 12.92

  defp rgb_to_xyz({r, g, b}) do
    {
      r * 0.649926 + g * 0.103455 + b * 0.197109,
      r * 0.234327 + g * 0.743075 + b * 0.022598,
      r * 0.000000 + g * 0.053077 + b * 1.035763
    }
  end

  defp xyz_to_xy({x, y, z}) do
    sum = x + y + z
    {x / sum, y / sum}
  end

  #
  #

  def rgb_to_hsv(r, g, b),  do: rgb_to_hsv({r, g, b})
  def rgb_to_hsv(rgb_tuple) do
    rgb_tuple |> rgb_to_normalized_hsv |> adjust_hsv
  end

  defp adjust_hsv({h, s, v}) do
    h = round(h * 65536 / 360)
    s = round(s * 255)
    v = round(v * 255)
    {h, s, v}
  end

  defp rgb_to_normalized_hsv({r, g, b}) do
    {min, max} = minmax(r, g, b)
    if max > 0 do
      delta = max - min
      h = case max do
            ^r ->     (g - b) / delta
            ^g -> 2 + (b - r) / delta
            ^b -> 4 + (r - g) / delta
          end
      s = delta / max
      v = max
      {h_to_degrees(h), s, v}
    else
      {0, 0, 0}
    end
  end

  defp minmax(r, g, b) do
    min = Kernel.min(r, Kernel.min(g, b))
    max = Kernel.max(r, Kernel.max(g, b))
    {min, max}
  end

  defp h_to_degrees(h) when h < 0, do: (h * 60) + 360
  defp h_to_degrees(h),            do:  h * 60

end