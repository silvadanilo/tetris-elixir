defmodule Tetris do
  use GenServer
  alias Tetris.{Bottom, Brick, Points}

  defmodule Game do
    defstruct [
      status: :waiting,
      score: 0,
      bottom: %{},
      current_brick: nil,
      next_brick: nil,
    ]

  end

  @doc false
  def start_link() do
    GenServer.start_link(__MODULE__, Game.__struct__())
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def state(game) do
    GenServer.call(game, :state)
  end

  def status(game) do
    GenServer.call(game, :status)
  end

  def start(game, attributes \\ []) do
    GenServer.call(game, {:start, attributes})
  end

  def stop(game) do
    GenServer.cast(game, :stop)
  end

  def try_left(game) do
    GenServer.call(game, {:try_move, &Brick.left/1})
  end

  def try_right(game) do
    GenServer.call(game, {:try_move, &Brick.right/1})
  end

  def try_spin_90(game) do
    GenServer.call(game, {:try_move, &Brick.spin_90/1})
  end

  def drop(game) do
    GenServer.call(game, :drop)
  end

  def brick(game) do
    GenServer.call(game, :brick)
  end

  def next_brick(game) do
    GenServer.call(game, :next_brick)
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_cast(:stop, _from, _state) do
    {:stop, :normal, :stop}
  end

  def handle_call({:start, attributes}, _from, state) do
    new_state = %Game{state |
      status: :playing,
      current_brick: attributes |> Keyword.get(:current_brick, create_brick()),
      next_brick: create_brick(),
      score: 0,
      bottom: attributes |> Keyword.get(:bottom, %{})
    }

    {:reply, new_state, new_state}
  end

  def handle_call(:brick, _from, state) do
    {:reply, state.current_brick, state}
  end

  def handle_call(:next_brick, _from, state) do
    {:reply, state.next_brick, state}
  end

  def handle_call({:try_move, f}, _from, state) do
    brick = state.current_brick
    shifted_brick = f.(brick)

    brick = if Bottom.collides?(state.bottom, prepare(shifted_brick)) do
      brick
    else
      shifted_brick
    end

    new_state = state |> Map.put(:current_brick, brick)
    {:reply, new_state, new_state}
  end

  def handle_call(:drop, _from, state) do
    shifted_brick = Brick.down(state.current_brick)

    new_state =
    if Bottom.collides?(state.bottom, prepare(shifted_brick)) do

      points =
        state.current_brick
        |> prepare()
        |> Points.with_color(Brick.color(state.current_brick))

      {count, new_bottom} =
        state.bottom
        |> Bottom.merge(points)
        |> Bottom.full_collapse()

      %Game{state |
        current_brick: state.next_brick,
        next_brick: create_brick(),
        bottom: new_bottom,
        score: state.score + calculate_score(count),
        status: case Bottom.collides?(new_bottom, prepare(state.next_brick)) do
          true -> :game_over
          false -> state.status
        end
      }
    else
      %Game{state |
        current_brick: shifted_brick,
        score: state.score + 1,
      }
    end

    {:reply, new_state, new_state}
  end

  defp calculate_score(0), do: 0
  defp calculate_score(count) do
    100 * round(:math.pow(2, count))
  end

  defp prepare(brick) do
    brick
    |> Brick.prepare()
    |> Points.move_to_location(brick.location)
  end

  defp create_brick() do
    Brick.new_random()
  end
end
