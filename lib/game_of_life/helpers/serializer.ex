defmodule GameOfLife.Helpers.Serializer do
  alias GameOfLife.Cells, as: Cells
  alias GameOfLife.UI, as: UI
  alias GameOfLife.GameController, as: GC
  import GameOfLife.Helpers.MathCommon, only: [map_position: 4]

  @inital_config_size 100
  @live_symbol "#"

  @spec serialize_current_state(String.t()) :: any()
  def serialize_current_state(path) do
    spawn(fn ->
      GC.send_state_request(self())

      receive do
        {:state, live_cells} ->
          save(path, live_cells)
      end
    end)
  end

  @spec save(String.t(), Cells.t()) :: any()
  defp save(path, live_cells) do
    live_cells
    |> Enum.map(fn {x, y} -> "#{x},#{y}" end)
    |> Enum.join("\n")
    |> write_to_file(path)
  end

  @spec write_to_file(String.t(), String.t()) :: any()
  defp write_to_file(data, path) do
    try do
      File.write!(path, data)
    rescue
      e in File.Error ->
        Exception.message(e)
        |> UI.print()
    end
  end

  @spec deserialize(String.t()) :: Cells.t()
  def deserialize(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.into(MapSet.new())
  end

  @spec with_initial_config(String.t()) :: Cells.t()
  def with_initial_config(path) do
    cells =
      path
      |> File.read!()
      |> String.split("\n")
      |> Enum.take(@inital_config_size)
      |> Enum.map(&String.split(&1, ""))
      |> Enum.map(&Enum.take(&1, @inital_config_size))

    rows = Enum.count(cells)
    cols = Enum.count(Enum.at(cells, 0))

    cells
    |> Enum.with_index()
    |> Enum.reduce(
      MapSet.new(),
      fn {row, y}, live_cells ->
        row
        |> Enum.with_index()
        |> Enum.reduce(
          MapSet.new(),
          fn {cell, x}, current_live_cells ->
            if cell === @live_symbol do
              MapSet.put(current_live_cells, map_position(x, y, rows, cols))
            else
              current_live_cells
            end
          end
        )
        |> MapSet.union(live_cells)
      end
    )
  end
end
