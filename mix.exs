defmodule GameOfLife.MixProject do
  use Mix.Project

  def project do
    [
      app: :game_of_life,
      version: "1.0.0",
      elixir: "> 1.3.2",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: GameOfLife],
      deps: deps()
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5.1"}
    ]
  end
end
