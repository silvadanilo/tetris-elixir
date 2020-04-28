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


end
