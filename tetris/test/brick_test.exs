defmodule BrickTest do
  use ExUnit.Case

  import Tetris.Brick
  alias Tetris.Points

  test "Creates a new brick" do
    assert new().name == :i
  end

  test "Creates a new random brick" do
    actual = new_random()

    assert actual.name in [:i, :l, :z, :o, :t]
    assert actual.rotation in [0, 90, 180, 270]
    assert actual.reflection in [true, false]
  end

  test "Brick manipulation" do
    brick = new(%{location: {40, 0}, rotation: 90})
    moved = brick
            |> left()
            |> left()
            |> right()
            |> down()
            |> spin_90()
            |> spin_90()
            |> spin_90()

    assert moved.rotation == 0
    assert moved.location == {39, 1}
  end

  test "should flip rotate flip and mirror" do
    [{1, 1}]
    |> Points.mirror
    |> assert_point({4, 1})
    |> Points.flip
    |> assert_point({4, 4})
    |> Points.rotate_90
    |> assert_point({1, 4})
    |> Points.rotate_90
    |> assert_point({1, 1})
  end

  test "should convert brick to string" do
    actual = new() |> Tetris.Brick.to_string
    expected = "□■□□\n□■□□\n□■□□\n□■□□"

    assert actual == expected
  end

  test "should inspect bricks" do
    actual = new() |> inspect
    expected =
      """
      □■□□
      □■□□
      □■□□
      □■□□
      {#{x_center()}, 0} false 0
      """

    assert "#{actual}\n" == expected
  end

  def assert_point([actual], expected) do
    assert actual == expected
    [actual]
  end
end
