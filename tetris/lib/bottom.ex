defmodule Tetris.Bottom do

  @board_width 10
  @board_height 20


  def merge(bottom, points) do
    points
    |> Enum.map(fn {x, y, c} -> {{x, y}, {x, y, c}} end)
    |> Enum.into(bottom)
  end

  def collides?(bottom, points) when is_list(points) do
    Enum.any?(points, &collides?(bottom, &1))
  end
  def collides?(bottom, {x, y, _color}), do: collides?(bottom, {x, y})
  def collides?(_bottom, {x, y}) when x < 1 or x > @board_width or y > @board_height, do: true
  def collides?(bottom, {x, y}) do
    !!Map.get(bottom, {x, y})
  end

  def complete_ys(bottom) do
    bottom
    |> Map.keys()
    |> Enum.map(&elem(&1, 1))
    # |> Enum.frequencies
    # |> Enum.filter(fn {row, count} -> count == 10 end)
    # |> Enum.map(&elem(&1, 0))
    |> Enum.uniq()
    |> Enum.filter(fn row -> complete?(bottom, row) end)
  end

  def complete?(bottom, row) do
    bottom
    |> Map.keys()
    |> Enum.filter(fn {_x, y} -> y == row end)
    |> Enum.count()
    |> Kernel.==(10)
  end

  def collapse_row(bottom, row) do
    bad_keys =
      bottom
      |> Map.keys
      |> Enum.filter(fn {_x, y} -> y == row end)

    bottom
    |> Map.drop(bad_keys)
    |> Enum.map(&move_bad_point_up(&1, row))
    |> Map.new
  end

  def move_bad_point_up({{x, y}, {x, y, color}}, row) when y < row do
    {{x, y+1}, {x, y+1, color}}
  end
  def move_bad_point_up(key_value, _row) do
    key_value
  end

  def full_collapse(bottom) do
    rows =
      bottom
      |> complete_ys
      |> Enum.sort

    new_bottom = Enum.reduce(rows, bottom, &collapse_row(&2, &1))

    {Enum.count(rows), new_bottom}
  end
end
