# Game Of Life

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

## Game of Life Engine

  Data structure used to store the current state of the universe is a set of x,y coordinates for live cells.
  When generating the new state, we take into consideration all the neighbours of the live cells, and of course
  the live cells themselves.

  After building the considered cells set, we compute a score for each cell based on how many
  live neighbours it has, including itself too.

  Based on this score then we filter the cells using the following rules:

    1. If the score is 3, then the cell will live
    2. If the score is 4, then the cell will live if it is live in the current generation
    3. Otherwise the cell will be dead

### Computational complexity

The time complexity for generating a new state is linear with the alive cells.
The idea is that if we have N alive cells, then we roughly have 9*N considered cells.
Computing the score for these cells takes 9*9*N steps.
If we consider the set operations to work in constant/O(1) time, then we roughly have 81*N operations.
That means that the complexity is O(n) amortized, in some cases O(n^2) if set/hash operations take linear time, but that should be rare for small N-s.
It is also linear, because we are taking only the alive cells, not the whole universe.

The space complexity should also be O(n) because we are working with two sets, one for the current alive cells, and one for the considered sets for the next generation.
It could also be O(n^2) when creating the new set of alive cells, but it is not as Elixir handles these copies with persistent data structures.

## Building and running

### Config

We have the following properties to configure:
    
   * Tick - the waiting time before generating the new universe
        
        `config :game_of_life, tick: 500`

   * Display limit - the maximum number of rows and cells to display
        
        `config :game_of_life, display_limit: 50`

### Build

`mix escript.build` - building and generating the CLI binary


### Run

`./game_of_life -s=10` - Universe with glider and dimension size 10

`./game_of_life -s 50 -i initial_configurations/gosper_glider_gun` - Universe with gosper's glider gun

`./game_of_life -s=100 -f saved_states/gospel_finish` - Universe with preloaded state

Observation: for running Game of Life with big universes, you should consider changing the font size of the console/terminal

### Tests

`mix test` - running tests

### Dialyzer

`mix deps.get` - to get dependencies

`mix dialyzer` - the first run takes some time to cache things