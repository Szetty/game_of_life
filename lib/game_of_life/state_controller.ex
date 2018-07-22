defmodule GameOfLife.StateController do
  alias GameOfLife.UI, as: UI
  alias GameOfLife.InputController, as: IC
  alias GameOfLife.Helpers.Serializer, as: Serializer
  alias GameOfLife.GameController, as: GC

  @process :state_controller
  @speeds %{
    1 => 900,
    2 => 700,
    3 => 500,
    4 => 300,
    5 => 100
  }

  @type state :: :continue | :pause | :save | :speed | :exit

  def start() do
    spawn_link(fn ->
      Process.register(self(), @process)
      continue()
    end)
  end

  # States

  defp continue() do
    receive do
      new_state -> handle_transition(:continue, new_state)
    after
      Application.get_env(:game_of_life, :tick) ->
        GC.tick()
        continue()
    end
  end

  defp pause() do
    receive do
      new_state -> handle_transition(:pause, new_state)
    end
  end

  # Transitions

  @spec handle_transition(state(), state()) :: any()
  defp handle_transition(old_state, new_state) do
    UI.print("Game transitioning from #{old_state} to state #{new_state}")

    case new_state do
      :continue -> handle_transition_to_continue()
      :pause -> handle_transition_to_pause()
      :speed -> change_speed(old_state)
      :save -> save(old_state)
      :exit -> exit()
    end
  end

  defp handle_transition_to_continue() do
    UI.continue()
    IC.continue()
    continue()
  end

  defp handle_transition_to_pause() do
    UI.continue()
    IC.continue()
    pause()
  end

  @spec change_speed(state()) :: any()
  defp change_speed(old_state) do
    try do
      speed = IC.get_input("New speed [1-5]: ") |> String.to_integer()

      new_tick =
        cond do
          speed < 1 -> @speeds[1]
          speed > 5 -> @speeds[5]
          true -> @speeds[speed]
        end

      Application.put_env(:game_of_life, :tick, new_tick)
      UI.print("Speed changed")
    rescue
      _ in ArgumentError ->
        UI.print("You need to provide a number")
        Process.sleep(1000)
    end

    handle_transition(:speed, old_state)
  end

  @spec save(state()) :: any()
  defp save(old_state) do
    path = IC.get_input("Saving the current configuration in: ")
    UI.print("Saving in the background")
    Serializer.serialize_current_state(path)
    Process.sleep(1000)
    handle_transition(:save, old_state)
  end

  defp exit() do
    UI.exit()
  end

  # Client

  @spec new_game_state(state()) :: any()
  def new_game_state(state) do
    send(@process, state)
  end
end
