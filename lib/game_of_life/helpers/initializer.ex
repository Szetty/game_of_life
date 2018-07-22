defmodule GameOfLife.Helpers.Initializer do
  alias GameOfLife.Cells, as: Cells
  alias GameOfLife.Helpers.Serializer, as: Serializer
  import GameOfLife.Helpers.MathCommon, only: [compute_universe_bounds: 1]

  @glider MapSet.new([{1, 2}, {2, 1}, {0, 0}, {1, 0}, {2, 0}])

  @spec initialize(keyword()) :: Cells.t()
  def initialize(opts) do
    Application.put_env(:game_of_life, :universe_bounds, compute_universe_bounds(opts[:size]))
    get_initial_state(opts)
  end

  @spec get_initial_state(keyword()) :: Cells.t()
  defp get_initial_state(opts) do
    file = Keyword.get(opts, :file)
    initial = Keyword.get(opts, :initial)

    cond do
      file !== nil -> Serializer.deserialize(file)
      initial !== nil -> Serializer.with_initial_config(initial)
      true -> @glider
    end
  end
end
