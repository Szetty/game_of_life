defmodule GameOfLife.GameController do
  alias GameOfLife.UI, as: UI
  alias GameOfLife.Game.Engine, as: Engine
  alias GameOfLife.Cells, as: Cells

  @process :game_controller

  @spec start(Cells.t()) :: any()
  def start(initial_state) do
    spawn_link(fn ->
      Process.register(self(), @process)
      loop(initial_state)
    end)
  end

  # Server

  @spec loop(Cells.t()) :: any()
  def loop(live_cells) do
    receive do
      :tick ->
        handle_tick(live_cells)

      {:state, pid} ->
        handle_send_state(live_cells, pid)
    end
  end

  @spec handle_send_state(Cells.t(), pid()) :: any()
  def handle_send_state(live_cells, pid) do
    send(pid, {:state, live_cells})
    loop(live_cells)
  end

  @spec handle_tick(Cells.t()) :: any()
  def handle_tick(live_cells) do
    live_cells = Engine.new_generation(live_cells)
    UI.game_output(live_cells)
    loop(live_cells)
  end

  # Client

  def tick() do
    send(@process, :tick)
  end

  @spec send_state_request(pid()) :: any()
  def send_state_request(pid) do
    send(@process, {:live_cells, pid})
  end
end
