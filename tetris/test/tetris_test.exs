defmodule TetrisTest do
  use ExUnit.Case
  import Tetris
  alias Tetris.Brick
  setup do
    {:ok,server_pid} = Tetris.start_link()
    Tetris.start(server_pid)
    {:ok,server: server_pid}
  end

  test "try to move, returns shifted brick on success", %{server: pid} do
    brick = brick(pid)

    expected = brick |> Brick.right
    actual = try_right(pid) |> Map.get(:current_brick)

    assert actual == expected
  end

  test "try to move, returns original brick on failure", %{server: pid} do
    brick = Brick.new(location: {8, 1})
    Tetris.start(pid, current_brick: brick)

    actual = try_right(pid) |> Map.get(:current_brick)

    assert actual == brick
  end

  test "drops without merging", %{server: pid} do
    brick = Brick.new(location: {5,5})
    Tetris.start(pid, current_brick: brick, bottom: %{})

    response = drop(pid)

    expecteds = %{
      current_brick: Brick.down(brick),
      bottom: %{},
      score: 1,
    }

    assert_contains(response, expecteds)
  end

  defp assert_contains(container, contained) do
    contained
    |> Enum.each(fn {key, value} -> assert container |> Map.get(key) == value end)
  end

  test "drops and merges", %{server: pid} do
    brick = Brick.new(location: {5,16})
    Tetris.start(pid, current_brick: brick, bottom: %{})

    response = drop(pid)

    assert Map.get(response.bottom, {7,20}) == {7, 20, :blue}
  end

  test "drops to bottom and compresses", %{server: pid} do
    brick = Brick.new(location: {5, 16})
    bottom =
      for x <- 1..10, y <- 17..20, x != 7 do
        {{x, y}, {x, y, :red}}
      end
      |> Map.new

    Tetris.start(pid, current_brick: brick, bottom: bottom)

    %{score: new_score, bottom: new_bottom } = drop(pid)

    assert new_bottom == %{}
    assert new_score == 1600
  end
end
