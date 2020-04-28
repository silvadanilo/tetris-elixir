defmodule TetrisTest do
  use ExUnit.Case
  import Tetris
  alias Tetris.Brick

  test "try to move, returns shifted brick on success" do
    brick = Brick.new(location: {5, 1})
    bottom = %{}

    expected = brick |> Brick.right
    actual = try_right(brick, bottom)

    assert actual == expected
  end

  test "try to move, returns original brick on failure" do
    brick = Brick.new(location: {8, 1})
    bottom = %{}

    actual = try_right(brick, bottom)

    assert actual == brick
  end

  test "drops without merging" do
    brick = Brick.new(location: {5,5})
    bottom = %{}

    expected = %{
      brick: Brick.down(brick),
      bottom: %{},
      score: 1,
      game_over: false
    }

    actual = drop(brick, bottom, :red)

    assert expected == actual
  end

  test "drops and merges" do
    brick = Brick.new(location: {5,16})
    bottom = %{}

    actual = drop(brick, bottom, :red)

    assert Map.get(actual.bottom, {7,20}) == {7, 20, :red}
  end

  test "drops to bottom and compresses" do
    brick = Brick.new(location: {5, 16})
    bottom =
      for x <- 1..10, y <- 17..20, x != 7 do
        {{x, y}, {x, y, :red}}
      end
      |> Map.new

    %{score: score, bottom: bottom } =
      Tetris.drop(brick, bottom, :red)

    assert bottom == %{}
    assert score == 1600
  end
end
