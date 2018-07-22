defmodule GameOfLife.UI.DisplayCalculator do
  @display_limit 50
  @cells_around 5

  alias GameOfLife.Cells, as: Cells
  alias GameOfLife.Universe, as: Universe

  @spec compute_display_size(Cells.t()) :: Universe.bounds()
  def compute_display_size(live_cells) do
    {minx, miny, maxx, maxy} = Application.get_env(:game_of_life, :universe_bounds)

    if maxx < @display_limit do
      {minx, miny, maxx, maxy}
    else
      compute_area_size(live_cells)
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

  @spec compute_area_size(Cells.t()) :: Universe.bounds()
  defp compute_area_size(live_cells) do
    live_cells
    |> Enum.reduce(
      {nil, nil, nil, nil},
      fn {x, y}, {minx, miny, maxx, maxy} ->
        if minx === nil do
          {x, y, x, y}
        else
          {
            min(minx, x) - @cells_around,
            min(miny, y) - @cells_around,
            max(maxx, x) + @cells_around,
            max(maxy, y) + @cells_around
          }
        end
      end
    )
  end
end
