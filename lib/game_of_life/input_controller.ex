defmodule GameOfLife.InputController do
  @process :input_controller

  def start() do
    spawn_link(fn ->
      Process.register(self(), @process)
      wait_for_user_input()
    end)
  end

  defp wait_for_user_input() do
    # We put 2 to handle line feed too
    input = get_input()
    GameOfLife.UI.user_input(input)
    wait_for_continue()
  end

  defp wait_for_continue() do
    receive do
      :continue -> wait_for_user_input()
    end
  end

  # Client

  def continue() do
    send(@process, :continue)
  end

  @spec get_input(String.t()) :: String.t()
  def get_input(prompt \\ "") do
    IO.gets(prompt) |> String.trim()
  end
end
