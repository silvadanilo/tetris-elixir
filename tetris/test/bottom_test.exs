defmodule Tetris.BottomTest do
  use ExUnit.Case, async: true
  import Tetris.Bottom

  test "various collision" do
    bottom = %{{1, 1} => {1, 1, :blue}}
    assert collides?(bottom, {1, 1, :blue})
    assert collides?(bottom, {1, 1, :red})
    refute collides?(bottom, {2, 1, :blue})
    refute collides?(bottom, [{1, 2, :blue}, {2, 1, :blue}])
    refute collides?(bottom, [{2, 2, :blue}, {2, 3, :blue}])
    assert collides?(bottom, [{2, 2, :blue}, {1, 1, :blue}])
  end

  test "border collision" do
    bottom = %{}
    # left side
    assert collides?(bottom, {0, 1, :blue})
    refute collides?(bottom, {1, 1, :blue})

    # right side
    assert collides?(bottom, {11, 1, :blue})
    refute collides?(bottom, {10, 1, :blue})

    # bottom side
    assert collides?(bottom, {1, 21, :blue})
    refute collides?(bottom, {1, 20, :blue})
  end

  test "simple merge" do
    bottom = %{{1, 1} => {1, 1, :blue}}

    merged = merge(bottom, [{1, 2, :red}, {1, 3, :red}])
    assert merged == %{
      {1, 1} => {1, 1, :blue},
      {1, 2} => {1, 2, :red},
      {1, 3} => {1, 3, :red}}
  end
end
