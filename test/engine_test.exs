defmodule EngineTest do
  use ExUnit.Case
  import GameOfLife.Game.Engine

  @glider MapSet.new([
            {1, 2},
            {2, 1},
            {0, 0},
            {1, 0},
            {2, 0}
          ])

  test "will live" do
    assert will_live?(3, false) === true
    assert will_live?(3, true) === true
    assert will_live?(4, true) === true
    assert will_live?(4, false) === false

    Enum.each(
      0..2,
      fn score ->
        assert will_live?(score, false) === false
        assert will_live?(score, true) === false
      end
    )

    Enum.each(
      5..9,
      fn score ->
        assert will_live?(score, false) === false
        assert will_live?(score, true) === false
      end
    )
  end

  test "get_neighbours" do
    Application.put_env(:game_of_life, :universe_bounds, {-5, -5, 5, 5})

    assert get_neighbours({0, 0}) ===
             MapSet.new([{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}])

    assert get_neighbours({-1, 1}) ===
             MapSet.new([{-2, 0}, {-1, 0}, {0, 0}, {-2, 1}, {0, 1}, {-2, 2}, {-1, 2}, {0, 2}])
  end

  test "get_score" do
    Application.put_env(:game_of_life, :universe_bounds, {-5, -5, 5, 5})

    [
      {[{-1, -1}, {-1, 0}, {-1, 1}, {0, 2}, {0, 3}, {1, 3}, {2, 3}, {3, -1}, {3, 2}], 1},
      {[{0, -1}, {0, 0}, {1, 2}, {2, -1}, {2, 2}, {3, 0}, {3, 1}], 2},
      {[{0, 1}, {1, -1}, {2, 0}], 3},
      {[{1, 0}, {2, 1}], 4},
      {[{1, 1}], 5}
    ]
    |> Enum.each(fn {positions, score} ->
      Enum.each(
        positions,
        fn position ->
          got = get_score(position, @glider)

          assert get_score(position, @glider) === score,
                 "Score for position #{inspect(position)} is #{got} instead of #{score}"
        end
      )
    end)
  end

  test "get_neighbour_position" do
    {minx, miny, maxx, maxy} = {-5, -5, 5, 5}
    Application.put_env(:game_of_life, :universe_bounds, {minx, miny, maxx, maxy})
    assert get_neighbour_position({-1, -1}, {3, 3}) === {2, 2}
    assert get_neighbour_position({1, -1}, {0, 0}) === {1, -1}
    assert get_neighbour_position({0, -1}, {0, miny}) === {0, maxy}
    assert get_neighbour_position({1, 0}, {maxx, 0}) === {minx, 0}
    assert get_neighbour_position({-1, -1}, {minx, miny}) === {maxx, maxy}
    assert get_neighbour_position({1, 1}, {maxx, maxy}) === {minx, miny}
    assert get_neighbour_position({-1, 1}, {minx, maxy}) === {maxx, miny}
    assert get_neighbour_position({1, -1}, {maxx, miny}) === {miny, maxy}
  end
end
