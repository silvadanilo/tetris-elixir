defmodule TetrisUiWeb.TetrisLive do
  use TetrisUiWeb, :live_view
  alias Tetris.{Brick,Points}
  alias TetrisUiWeb.BrickHelper

  @debug true

  @impl true
  def terminate(_reason, %{assigns: %{game: game}}) do
    Tetris.stop(game)
    :ok
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval 300, self(), :tick
      {:ok, waiting_room(socket)}
    else
      {:ok, assign(socket, status: :not_connected)}
    end
  end

  defp waiting_room(socket) do
    {:ok, game} = Tetris.start_link()
    assign(socket, game: game, status: :waiting)
  end

  defp new_game(socket = %{assigns: %{game: game}}) do
    Tetris.start(game)
    |> show(socket)
  end

  defp show(response, socket) do
    assign(socket,
      current_brick: response.current_brick,
      tetromino: response.current_brick |> Brick.render() |> BrickHelper.render_brick(),
      next_tetromino: response.next_brick |> Brick.shape() |> Points.with_color(Brick.color(response.next_brick)) |> BrickHelper.render_brick(),
      score: response.score,
      bottom: response.bottom |> Map.values() |> BrickHelper.render_brick(),
      status: response.status
    )
  end

  defp drop(socket = %{assigns: %{status: :playing, game: game}}) do
    Tetris.drop(game)
    |> show(socket)
  end
  defp drop(socket), do: socket

  def move(direction, %{assigns: %{game: game}} = socket) do
    direction.(game)
    |> show(socket)
  end

  @impl true
  def render(%{status: :playing} = assigns) do
    TetrisUiWeb.LayoutView.render("tetris.html", assigns)
  end

  def render(%{status: :waiting} = assigns) do
    ~L"""
      <h1>Welcome to Tetris!</h1>
      <button phx-click="start-game">Start</button>
    """
  end

  def render(%{status: :pause} = assigns) do
    ~L"""
      <h1><%= @score %></h1>
      <button phx-click="continue-game">Continue</button>
      <%= debug(assigns) %>
    """
  end

  def render(%{status: :game_over} = assigns) do
    ~L"""
      <h1>Game Over</h1>
      <h2>Your score is: <%= @score %></h2>
      <button phx-click="start-game">Play again</button>
      <%= debug(assigns) %>
    """
  end

  def render(%{status: :not_connected} = assigns) do
    ~L"""
      <h2>Waiting.....</h2>
    """
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket), do: {:noreply, move(&Tetris.try_left/1, socket)}
  def handle_event("left", _, socket), do: {:noreply, move(&Tetris.try_left/1, socket)}

  def handle_event("keydown", %{"key" => "ArrowRight"}, socket), do: {:noreply, move(&Tetris.try_right/1, socket)}
  def handle_event("right", _, socket), do: {:noreply, move(&Tetris.try_right/1, socket)}

  def handle_event("keydown", %{"key" => "ArrowUp"}, socket), do: {:noreply, move(&Tetris.try_spin_90/1, socket)}
  def handle_event("up", _, socket), do: {:noreply, move(&Tetris.try_spin_90/1, socket)}

  def handle_event("keydown", %{"key" => "ArrowDown"}, socket), do: {:noreply, drop(socket)}
  def handle_event("down", _, socket), do: {:noreply, drop(socket)}

  def handle_event("keydown", _, socket), do: {:noreply, socket}

  def handle_event("start-game", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_event("pause-game", _, socket) do
    {:noreply, assign(socket, status: :pause)}
  end

  def handle_event("continue-game", _, socket) do
    {:noreply, assign(socket, status: :playing)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, drop(socket)}
  end

  def debug(assigns), do: debug(assigns, @debug, Mix.env)
  def debug(assigns, true, :dev) do
    ~L"""
    <pre>
    <%= raw( @current_brick |> inspect) %>
    </pre>
    """
  end
  def debug(_, _, _), do: ""
end
