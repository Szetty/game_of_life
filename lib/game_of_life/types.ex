defmodule GameOfLife.Cells do
  @type t :: MapSet.t(GameOfLife.Cell.t())
end

defmodule GameOfLife.Cell do
  @type t :: {integer(), integer()}
end

defmodule GameOfLife.Universe do
  @type bounds :: {integer(), integer(), integer(), integer()}
end
