defmodule Tetris.Brick do
  alias Tetris.Points

  @x_center 2

  defstruct [
    name: :i,
    location: {@x_center, 0},
    rotation: 0,
    reflection: false,
  ]

  def new(attributes \\ []), do: __struct__(attributes)

  def new_random() do
    %__MODULE__{
      name: random_name(),
      location: {@x_center, 0},
      rotation: random_rotation(),
      reflection: random_reflection(),
    }
  end

  def down(%__MODULE__{} = brick) do
    %__MODULE__{brick | location: point_down(brick.location)}
  end

  def left(%__MODULE__{} = brick) do
    %__MODULE__{brick | location: point_left(brick.location)}
  end

  def right(%__MODULE__{} = brick) do
    %__MODULE__{brick | location: point_right(brick.location)}
  end

  def spin_90(%__MODULE__{} = brick) do
    %__MODULE__{brick | rotation: rotate(brick.rotation)}
  end

  def shape(%{name: :l}) do
    [
      {2, 1},
      {2, 2},
      {2, 3}, {3, 3}
    ]
  end

  def shape(%{name: :i}) do
    [
      {2, 1},
      {2, 2},
      {2, 3},
      {2, 4},
    ]
  end

  def shape(%{name: :z}) do
    [
      {2, 2},
      {2, 3}, {3, 3},
              {3, 4},
    ]
  end

  def shape(%{name: :o}) do
    [
      {2, 2}, {3, 2},
      {2, 3}, {3, 3},
    ]
  end

  def shape(%{name: :t}) do
    [
      {2, 1},
      {2, 2}, {3, 2},
      {2, 3},
    ]
  end

  def prepare(brick) do
    brick
    |> shape()
    |> Points.rotate(brick.rotation)
    |> Points.mirror(brick.reflection)
  end

  def render(block) do
    block
    |> prepare
    |> Points.move_to_location(block.location)
    |> Points.with_color(block |> color())
  end

  def to_string(brick) do
    brick
    |> prepare()
    |> Points.to_string()
  end

  def print(brick) do
    brick
    |> prepare()
    |> Points.print()

    brick
  end

  def x_center(), do: @x_center

  defp color(%{name: :i}), do: :blue
  defp color(%{name: :l}), do: :green
  defp color(%{name: :z}), do: :orange
  defp color(%{name: :o}), do: :red
  defp color(%{name: :t}), do: :grey

  defp rotate(270), do: 0
  defp rotate(degrees), do: degrees + 90

  defp point_left({x, y}) do
    {x - 1, y}
  end

  defp point_right({x, y}) do
    {x + 1, y}
  end

  defp point_down({x, y}) do
    {x, y + 1}
  end

  defp random_name() do
    ~w(i l z o t)a
    |> Enum.random()
  end

  defp random_rotation() do
    [0, 90, 180, 270]
    |> Enum.random()
  end

  defp random_reflection() do
    [true, false]
    |> Enum.random()
  end
end
