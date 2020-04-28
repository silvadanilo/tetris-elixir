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

  test "compute complete ys" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    assert complete_ys(bottom) == [20]
  end

   test "collapse single row" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])
    actual = Map.keys(collapse_row(bottom, 20))
    refute {19, 19} in actual
    assert {19, 20} in actual
    assert Enum.count(actual) == 1
  end

  test "full collapse with single row" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])
    {actual_count, actual_bottom} = full_collapse(bottom)

    assert actual_count == 1
    assert {19, 20} in Map.keys(actual_bottom)
  end

  defp new_bottom(complete_row, xtras) do
    (xtras ++
    (1..10
      |> Enum.map(fn x ->
        {{x, complete_row}, {x, complete_row, :red}}
      end)))
    |> Map.new()
  end
end
