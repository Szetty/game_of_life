defmodule GameOfLife.UI do
  alias GameOfLife.StateController, as: SC
  alias GameOfLife.GameController, as: GC
  alias GameOfLife.UI.UniverseDisplayer, as: Displayer
  alias GameOfLife.InputController, as: IC

  @process :ui
  @controls "Controls: (c)ontinue, (p)ause, (s)ave, change spee(d), (e)xit"

  def start(initial_state) do
    Process.register(self(), @process)
    GC.start(initial_state)
    SC.start()
    IC.start()
    loop()
  end

  # Server

  defp loop() do
    print_controls()

    receive do
      {:user_input, letter} -> on_user_input(letter)
      {:game_output, output} -> on_game_output(output)
    end
  end

  defp wait_for_game_controller() do
    receive do
      :continue -> loop()
      :exit -> :ok
    end
  end

  defp on_user_input(letter) do
    case get_state(letter) do
      nil ->
        IO.puts("Control #{letter} is not recognized")
        IC.continue()
        loop()

      state ->
        SC.new_game_state(state)
        wait_for_game_controller()
    end
  end

  defp on_game_output(output) do
    if Enum.count(output) === 0 do
      IO.puts("All cells have died")
    else
      output
      |> Displayer.build()
      |> IO.puts()

      loop()
    end
  end

  defp print_controls() do
    IO.puts("#{DateTime.utc_now()}  #{@controls}")
  end

  @spec get_state(String.t()) :: SC.state() | nil
  defp get_state(letter) do
    case letter do
      "c" -> :continue
      "p" -> :pause
      "e" -> :exit
      "s" -> :save
      "d" -> :speed
      _ -> nil
    end
  end

  # Client

  def user_input(input) do
    send(@process, {:user_input, input})
  end

  def game_output(output) do
    send(@process, {:game_output, output})
  end

  def continue() do
    send(@process, :continue)
  end

  def exit() do
    send(@process, :exit)
  end

  @spec print(String.t()) :: any()
  def print(message) do
    IO.puts(message)
  end
end
