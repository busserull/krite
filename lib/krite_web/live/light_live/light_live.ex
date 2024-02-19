defmodule KriteWeb.LightLive do
  use KriteWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :light, 60)}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light" style={"width: #{@light}%; background-color: #fcff90"}>
      Brightness: <%= @light %>%
    </div>

    <form phx-change="slide">
      <input type="range" phx-debounce="250" min="0" max="100" name="light" value={"#{@light}"} />
    </form>

    <button style="border: 1px solid #ececec; padding: 5px 10px; margin: 10px;" phx-click="off">
      Light off
    </button>

    <button style="border: 1px solid #ececec; padding: 5px 10px; margin: 10px;" phx-click="down">
      -10
    </button>

    <button style="border: 1px solid #ececec; padding: 5px 10px; margin: 10px;" phx-click="up">
      +10
    </button>

    <button style="border: 1px solid #ececec; padding: 5px 10px; margin: 10px;" phx-click="on">
      Light on
    </button>

    <button style="border: 1px solid #ececec; padding: 5px 10px; margin: 10px;" phx-click="random">
      Throw a disco party
    </button>
    """
  end

  def handle_event("on", _, socket) do
    {:noreply, assign(socket, light: 100)}
  end

  def handle_event("off", _, socket) do
    {:noreply, assign(socket, light: 0)}
  end

  def handle_event("slide", %{"light" => light_value}, socket) do
    {light, _} = Integer.parse(light_value)
    {:noreply, assign(socket, light: light)}
  end

  def handle_event("up", _, socket) do
    {:noreply, update(socket, :light, &min(&1 + 10, 100))}
  end

  def handle_event("down", _, socket) do
    {:noreply, update(socket, :light, &max(&1 - 10, 0))}
  end

  def handle_event("random", _, socket) do
    {:noreply, assign(socket, light: Enum.random(1..100))}
  end
end
