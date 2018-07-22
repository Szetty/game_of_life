defmodule GameOfLife.UI.UniverseDisplayer do
  alias GameOfLife.UI.DisplayCalculator, as: DisplayCalculator
  alias GameOfLife.Cells, as: Cells

  @live_character "#"
  @dead_character "."
  @separator " "

  @spec build(Cells.t()) :: String.t()
  def build(live_cells) do
    {minx, miny, maxx, maxy} = DisplayCalculator.compute_display_size(live_cells)
    col_sep_length = DisplayCalculator.compute_column_separator_length([minx, miny, maxx, maxy])
    col_sep = String.duplicate(" ", col_sep_length)
    columns = get_columns(minx..maxx, col_sep_length)
    cells = get_cells(live_cells, minx, miny, maxx, maxy, col_sep, col_sep_length)
    "#{cells}\n#{columns}"
  end

  @spec get_columns(Range.t(integer(), integer()), pos_integer) :: String.t()
  def get_columns(col_headers, col_sep_length) do
    col_sep = String.duplicate(@separator, col_sep_length - 1)

    Enum.reduce(col_headers, col_sep, fn col_header, acc ->
      header = Integer.to_string(col_header)
      sep_length = DisplayCalculator.calculate_sep_length_for_row_header(header, col_sep_length)
      sep = String.duplicate(@separator, sep_length)
      acc <> sep <> header
    end)
  end

  @spec get_cells(Cells.t(), integer(), integer(), integer(), integer(), String.t(), pos_integer) ::
          String.t()
  def get_cells(live_cells, minx, miny, maxx, maxy, col_sep, col_sep_length) do
    Enum.map(
      maxy..miny,
      fn y ->
        cells =
          Enum.map(
            minx..maxx,
            fn x ->
              if(MapSet.member?(live_cells, {x, y})) do
                @live_character
              else
                @dead_character
              end
            end
          )
          |> Enum.join(col_sep)

        row_header = Integer.to_string(y)

        sep_length =
          DisplayCalculator.calculate_sep_length_for_row_header(row_header, col_sep_length)

        sep = String.duplicate(@separator, sep_length)
        "#{row_header}#{sep}#{cells}"
      end
    )
    |> Enum.join("\n")
  end
end
