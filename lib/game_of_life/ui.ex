defmodule GameOfLife.UI do
  alias GameOfLife.StateController, as: SC
  alias GameOfLife.GameController, as: GC
  alias GameOfLife.UI.UniverseDisplayer, as: Displayer
  alias GameOfLife.InputController, as: IC

  @process :ui
  @controls "Controls: (c)ontinue, (p)ause, (s)ave, change spee(d), (e)xit"
  @status_agent :status_agent

  def start(initial_state) do
    initialize_alive_cells_agent(initial_state)
    Process.register(self(), @process)
    GC.start(initial_state)
    SC.start()
    IC.start()
    loop()
  end

  def initialize_alive_cells_agent(initial_state) do
    alive_cells_nr = Enum.count(initial_state)
    Agent.start_link fn ->
      Process.register(self(), @status_agent)
      {1, alive_cells_nr}
    end
  end

  # Server

  defp loop() do
    print_controls()

    receive do
      {:user_input, letter} -> on_user_input(letter)
      {:game_output, output} -> on_game_output(output)
    end
  end

  defp wait_for_notify() do
    receive do
      :continue -> loop()
      :exit -> :ok
    end
  end

  defp on_user_input(letter) do
    case get_state(letter) do
      nil ->
        print("Control #{letter} is not recognized")
        IC.continue()
        loop()

      state ->
        SC.new_game_state(state)
        wait_for_notify()
    end
  end

  defp on_game_output(output) do
    alive_cells_nr = Enum.count(output)
    update_alive_cells_nr_and_increment_gen_nr(alive_cells_nr)
    if alive_cells_nr === 0 do
      print("All cells have died")
    else
      output
      |> Displayer.build()
      |> print

      loop()
    end
  end

  @spec print_controls() :: any()
  defp print_controls() do
    {gen_nr, alive_cells_nr} = get_alive_cells_and_generation_nr()
    print("#{DateTime.utc_now()} Generation ##{gen_nr} Alive cells: #{alive_cells_nr}")
    print("#{@controls}")
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

  @spec get_alive_cells_and_generation_nr :: {non_neg_integer(), pos_integer()}
  def get_alive_cells_and_generation_nr(), do: Agent.get(@status_agent, fn numbers -> numbers end)
  @spec update_alive_cells_nr_and_increment_gen_nr(non_neg_integer()) :: any()
  def update_alive_cells_nr_and_increment_gen_nr(alive_cells_nr) do
    Agent.update(@status_agent, fn {gen_nr, _} -> {gen_nr + 1, alive_cells_nr} end)
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
