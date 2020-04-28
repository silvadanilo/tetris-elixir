defmodule TetrisUiWeb.TetrisLive do
  use TetrisUiWeb, :live_view
  alias Tetris.{Brick,Points}

  @debug true
  @box_width 20
  @box_height 20

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval 300, self(), :tick

    {:ok, start_game(socket)}
  end

  defp start_game(socket) do
    assign(socket,
      state: :starting,
    )
  end

  defp new_game(socket) do
    assign(socket,
      state: :playing,
      score: 0,
      bottom: %{},
    )
    |> new_brick()
    |> show()
  end

  defp new_brick(socket) do
    brick =
      Brick.new_random()
      |> Map.put(:location, {3, -3})

    assign(socket, brick: brick)
  end

  def show(socket) do
    brick = socket.assigns.brick

    points =
      brick
      |> Brick.prepare()
      |> Points.move_to_location(brick.location)
      |> Points.with_color(color(brick))

    assign(socket, tetromino: points)
  end

  def drop(%{assigns: %{state: :playing, brick: old_brick, bottom: bottom}} = socket) do
    response =
      Tetris.drop(old_brick, bottom, color(old_brick))

    socket
    |> assign(
      brick: response.brick,
      bottom: response.bottom,
      score: socket.assigns.score + response.score,
      state: (if response.game_over, do: :game_over, else: :playing)
    )
    |> show
  end
  def drop(socket), do: socket

  def move(direction, socket) do
    socket
    |> do_move(direction)
    |> show()
  end

  def do_move(%{assigns: %{brick: brick, bottom: bottom}} = socket, :turn) do
    assign(
      socket,
      brick: brick |> Tetris.try_spin_90(bottom))
  end

  def do_move(%{assigns: %{brick: brick, bottom: bottom}} = socket, :left) do
    assign(
      socket,
      brick: brick |> Tetris.try_left(bottom))
  end

  def do_move(%{assigns: %{brick: brick, bottom: bottom}} = socket, :right) do
    assign(
      socket,
      brick: brick |> Tetris.try_right(bottom))
  end

  def render(%{state: :starting} = assigns) do
    ~L"""
      <h1>Welcome to Tetris!</h1>
      <button phx-click="start-game">Start</button>
    """
  end

  def render(%{state: :playing} = assigns) do
    ~L"""
      <h1><%= @score %></h1>
      <div phx-window-keydown="keydown">
        <%= raw svg_head() %>
        <%= raw render_brick(@tetromino) %>
        <%= raw render_brick(Map.values(@bottom)) %>
        <%= raw svg_foot() %>
        <%= debug(assigns) %>
      </div>
    """
  end

  def render(%{state: :game_over} = assigns) do
    ~L"""
      <h1>Game Over</h1>
      <h2>Your score is: <%= @score %></h2>
      <button phx-click="start-game">Play again</button>
      <%= debug(assigns) %>
    """
  end

  def svg_head() do
    """
    <svg
    version="1.0"
    style="background-color: #F4F4F4"
    id="Layer_1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    width="200" height="400"
    viewBox="0 0 200 400"
    xml:space="preserve" style="border: 1px solid red;">
    """
  end

  def svg_foot(), do: "</svg>"

  def render_brick(cells) do
    cells
    |> Enum.map(fn {x, y, color} ->
      box({x, y}, color)
    end)
    |> Enum.join("\n")
  end

  def box(point, color) do
    """
    #{square(point, shades(color).light)}
    #{triangle(point, shades(color).dark)}
    """
  end

def square(point, shade) do
    {x, y} = to_pixels(point)
    """
    <rect
      x="#{x+1}" y="#{y+1}"
      style="fill:##{shade};"
      width="#{@box_width - 2}" height="#{@box_height - 2}"/>
    """
  end

  def triangle(point, shade) do
    {x, y} = to_pixels(point)
    {w, h} = {@box_width, @box_height}

    """
    <polyline
        style="fill:##{shade}"
        points="#{x + 1},#{y + 1} #{x + w},#{y + 1} #{x + w},#{y + h}" />
    """
  end

  defp to_pixels({x, y}), do: {(x - 1) * @box_width, (y - 1) * @box_height}

  defp shades(:red), do:    %{ light: "DB7160", dark: "AB574B"}
  defp shades(:blue), do:   %{ light: "83C1C8", dark: "66969C"}
  defp shades(:green), do:  %{ light: "8BBF57", dark: "769359"}
  defp shades(:orange), do: %{ light: "CB8E4E", dark: "AC7842"}
  defp shades(:grey), do:   %{ light: "A1A09E", dark: "7F7F7E"}

  defp color(%{name: :i}), do: :blue
  defp color(%{name: :l}), do: :green
  defp color(%{name: :z}), do: :orange
  defp color(%{name: :o}), do: :red
  defp color(%{name: :t}), do: :grey

  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, move(:left, socket)}
  end

  def handle_event("keydown", %{"key" => "ArrowRight"}, socket) do
    {:noreply, move(:right, socket)}
  end

  def handle_event("keydown", %{"key" => "ArrowUp"}, socket) do
    {:noreply, move(:turn, socket)}
  end

  def handle_event("keydown", %{"key" => "ArrowDown"}, socket) do
    {:noreply, drop(socket)}
  end

  def handle_event("keydown", _, socket) do
    {:noreply, socket}
  end

  def handle_event("start-game", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, drop(socket)}
  end

  def debug(assigns), do: debug(assigns, @debug, Mix.env)
  def debug(assigns, true, :dev) do
    ~L"""
    <pre>
    <%= raw( @tetromino |> inspect) %>
    <%= raw( @bottom |> inspect) %>
    </pre>
    """
  end
  def debug(_, _, _), do: ""
end
