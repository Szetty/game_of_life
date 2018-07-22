defmodule SerializerTest do
  use ExUnit.Case
  import GameOfLife.Helpers.Serializer

  test "with_initial_config" do
    assert with_initial_config("initial_configurations/glider") ===
             MapSet.new([{-1, -1}, {0, -1}, {1, -1}, {1, 0}, {0, 1}])

    assert with_initial_config("initial_configurations/gosper_glider_gun") ===
             MapSet.new([
               {4, 0},
               {18, 2},
               {-7, -1},
               {-1, -2},
               {-17, -1},
               {-2, -3},
               {7, -2},
               {-16, -1},
               {5, -1},
               {3, 1},
               {17, 2},
               {-5, 2},
               {7, 4},
               {-1, 0},
               {-6, 1},
               {-2, 1},
               {-1, -1},
               {-7, 0},
               {3, 0},
               {-5, -4},
               {4, 1},
               {-17, 0},
               {-16, 0},
               {4, 2},
               {-3, -1},
               {5, 3},
               {0, -1},
               {-7, -2},
               {3, 2},
               {-6, -3},
               {7, -1},
               {-4, 2},
               {-4, -4},
               {17, 1},
               {18, 1},
               {7, 3}
             ])
  end
end
