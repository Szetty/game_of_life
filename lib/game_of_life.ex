defmodule GameOfLife do
  @moduledoc """
  Documentation for the Game Of Life CLI.

  This command line tool simulates Conway's Game of Life in 2D.

  The simulation happens in a so called universe.
  The universe has the following properties:
    1. infinite, two-dimensional orthogonal grid of square cells
    2. the middle of the universe is (0,0)
    3. horizontal coordinates grow from left to right
    4. vertical coordinates grow from bottom to top

  Flags:
    --size,    -s ->  Dimension size, both vertical and horizontal dimensions will have this size
    --file,    -f ->  Load saved state from file
    --initial, -i ->  This flag specifies an initial 100x100 config
                      If the file has more than 100x100 cells, they will be ignored
                      If it has less cells, it will still be positioned on the middle of the universe
                      Column size needs to be the same for all rows
                      Symbol for live cells is '#', for dead cells it can be anything else
                      You can find examples in folder initial_configurations
  """

  alias GameOfLife.Helpers.Initializer, as: Init
  alias GameOfLife.UI, as: UI
  import Keyword, only: [has_key?: 2, get: 2]

  @flags [help: :boolean, size: :integer, file: :string, initial: :string]
  @aliases [s: :size, f: :file, i: :initial]

  def main(args) do
    {opts, _} = OptionParser.parse!(args, switches: @flags, aliases: @aliases)

    case validate(opts) do
      :help ->
        IO.puts(@moduledoc)

      {:error, error} ->
        IO.puts(error)

      :ok ->
        opts
        |> Init.initialize()
        |> UI.start()
    end
  end

  defp validate(opts) do
    cond do
      has_key?(opts, :help) ->
        :help

      !has_key?(opts, :size) ->
        {:error, "Missing option --size"}

      get(opts, :size) < 5 ->
        {:error, "Dimension size should be bigger than 5"}

      has_key?(opts, :initial) && has_key?(opts, :file) ->
        {:error, "Cannot work with both initial and file flag"}

      true ->
        :ok
    end
  end
end
