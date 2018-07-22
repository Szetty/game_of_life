defmodule GameOfLife.Game.Engine do
  @moduledoc """
  Documentation for the Game Of Life Engine.

  Data structure used to store the current state of the universe is a set of x,y coordinates for live cells.
  When generating the new state, we take into consideration all the neighbours of the live cells, and of course
  the live cells themselves.

  After building the considered cells set, we compute a score for each cell based on how many
  live neighbours it has, including itself too.

  Based on this score then we filter the cells using the following rules:

    1. If the score is 3, then the cell will live
    2. If the score is 4, then the cell will live if it is live in the current generation
    3. Otherwise the cell will be dead
  """

  alias GameOfLife.Cells, as: Cells
  alias GameOfLife.Cell, as: Cell
  import GameOfLife.Helpers.MathCommon, only: [wrap: 3]

  @neighbour_offsets [
    {-1, -1},
    {0, -1},
    {1, -1},
    {-1, 0},
    {1, 0},
    {-1, 1},
    {0, 1},
    {1, 1}
  ]

  @type offset :: {-1..1, -1..1}

  @spec new_generation(Cells.t()) :: Cells.t()
  def new_generation(live_cells) do
    live_cells
    |> considered_cells
    |> decide_new_cells(live_cells)
  end

  @spec considered_cells(Cells.t()) :: Cells.t()
  def considered_cells(live_cells) do
    live_cells
    |> Enum.reduce(
      MapSet.new(),
      fn cell, cells ->
        cell
        |> get_neighbours
        |> MapSet.put(cell)
        |> MapSet.union(cells)
      end
    )
  end

  @spec get_neighbours(Cell.t()) :: Cells.t()
  def get_neighbours(cell) do
    @neighbour_offsets
    |> Enum.map(&get_neighbour_position(&1, cell))
    |> MapSet.new()
  end

  @spec get_score(offset, Cell.t()) :: Cell.t()
  def get_neighbour_position({offset_x, offset_y}, {cell_x, cell_y}) do
    {minx, miny, maxx, maxy} = Application.get_env(:game_of_life, :universe_bounds)

    {
      (offset_x + cell_x) |> wrap(minx, maxx),
      (offset_y + cell_y) |> wrap(miny, maxy)
    }
  end

  @spec decide_new_cells(Cells.t(), Cells.t()) :: Cells.t()
  def decide_new_cells(considered_cells, live_cells) do
    considered_cells
    |> Enum.filter(fn cell ->
      cell
      |> get_score(live_cells)
      |> will_live?(MapSet.member?(live_cells, cell))
    end)
    |> Enum.into(MapSet.new())
  end

  @doc """
  Calculates how many cells are living
  Takes into account the 8 neighbours and the current cell
  """
  @spec get_score(Cell.t(), Cells.t()) :: 0..9
  def get_score(cell, live_cells) do
    cell
    |> get_neighbours
    |> MapSet.put(cell)
    |> Enum.count(&MapSet.member?(live_cells, &1))
  end

  @spec will_live?(0..9, boolean()) :: boolean()

  def will_live?(3, _), do: true
  def will_live?(4, live?), do: live?
  def will_live?(_, _), do: false
end
