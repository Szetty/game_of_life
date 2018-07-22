defmodule MathCommonTest do
  use ExUnit.Case
  import GameOfLife.Helpers.MathCommon

  test "wrap" do
    assert wrap(3, -1, 5) === 3
    assert wrap(5, -1, 1) === -1
    assert wrap(0, 1, 4) === 4
  end

  test "map_index" do
    assert map_position(0, 0, 5, 5) === {-2, 2}
    assert map_position(0, 0, 10, 10) === {-5, 4}
    assert map_position(4, 4, 5, 5) === {2, -2}
    assert map_position(9, 9, 10, 10) === {4, -5}
  end

  test "compute_universe_bounds" do
    assert compute_universe_bounds(5) === {-2, -2, 2, 2}
    assert compute_universe_bounds(10) === {-5, -5, 4, 4}
  end
end
