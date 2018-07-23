defmodule GameOfLife.UI.DisplayCalculator do
  @cells_around 5

  alias GameOfLife.Cells, as: Cells
  alias GameOfLife.Universe, as: Universe
  import GameOfLife.Helpers.MathCommon, only: [bounds_to_dimension_size: 1]

  @spec compute_display_size(Cells.t()) :: Universe.bounds()
  def compute_display_size(live_cells) do
    display_limit = Application.get_env(:game_of_life, :display_limit)
    bounds = Application.get_env(:game_of_life, :universe_bounds)
    size = bounds_to_dimension_size(bounds)
    if size <= display_limit do
      bounds
    else
      {minx, miny, maxx, maxy} = compute_potential_area_size(bounds, live_cells)
      {minx, maxx} = get_actual_area_size({minx, maxx}, display_limit)
      {miny, maxy} = get_actual_area_size({miny, maxy}, display_limit)
      IO.inspect({minx, maxx, miny, maxy})
      {minx, miny, maxx, maxy}
    end
  end

  @spec compute_column_separator_length(list(integer())) :: integer()
  def compute_column_separator_length(extremes) do
    extremes
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(&String.length/1)
    |> Enum.max()
  end

  @spec calculate_sep_length_for_row_header(String.t(), pos_integer()) :: pos_integer()
  def calculate_sep_length_for_row_header(header, col_sep_length) do
    col_sep_length - String.length(header) + 1
  end

  @spec compute_potential_area_size(Universe.bounds(), Cells.t()) :: Universe.bounds()
  defp compute_potential_area_size({bound_minx, bound_miny, bound_maxx, bound_maxy}, live_cells) do
    {minx, miny, maxx, maxy} = live_cells
    |> Enum.reduce(
      {nil, nil, nil, nil},
      fn {x, y}, {minx, miny, maxx, maxy} ->
        if minx === nil do
          {x, y, x, y}
        else
          {min(minx, x), min(miny, y), max(maxx, x), max(maxy, y)}
        end
      end
    )
    {
      max(minx - @cells_around, bound_minx),
      max(miny - @cells_around, bound_miny),
      min(maxx + @cells_around, bound_maxx),
      min(maxy + @cells_around, bound_maxy)
    }
  end

  defp get_actual_area_size({min, max}, display_limit) do
    if max - min > display_limit do
      {trunc(-display_limit / 2), trunc(display_limit / 2)}
    else
      {min, max}
    end
  end
end
