defmodule GameOfLife.Helpers.MathCommon do
  alias GameOfLife.Universe, as: Universe

  # It gets a dimension size, and returns the bounds of the universe according to the specifications
  @spec compute_universe_bounds(pos_integer()) :: Universe.bounds()
  def compute_universe_bounds(dimension_size) do
    size = trunc((dimension_size - 1) / 2)
    if rem(dimension_size, 2) === 0 do
      {-size - 1, -size - 1, size, size}
    else
      {-size, -size, size, size}
    end
  end

  @spec bounds_to_dimension_size(Universe.bounds()) :: pos_integer()
  def bounds_to_dimension_size({lower_bound, _, upper_bound, _}) do
    abs(lower_bound) + upper_bound + 1
  end

  @doc """
  We want to map for example the interval 0..100 in the following way:
    for x: 0..100 -> -50..49
    for y: 0..100 -> 49..-50
  """
  @spec map_position(non_neg_integer(), non_neg_integer(), pos_integer(), pos_integer()) ::
          {integer(), integer()}
  def map_position(x, y, rows, cols) do
    {x - trunc(cols / 2), -y + round(rows / 2) - 1}
  end

  @doc """
  Wraps around a value respecting minimum and maximum values
  """
  @spec wrap(integer(), integer(), integer()) :: integer()
  def wrap(value, min, max) do
    cond do
      value > max -> min
      value < min -> max
      true -> value
    end
  end
end
