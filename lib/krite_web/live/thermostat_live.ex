defmodule KriteWeb.ThermostatLive do
  use KriteWeb, :live_view

  def render(assigns) do
    ~H"""
    Controlling temperature for <%= @house %> <br /> Budeie? <%= @budeie %> <br />
    Current temperature: <%= @temperature %>°C <button phx-click="inc_temperature">+</button>
    """
  end

  def mount(%{"house" => house}, session, socket) do
    temperature = 22

    budeie_string = Map.get(session, "budeie_id", "No budeie logged in")

    reply_socket =
      socket
      |> assign(:temperature, temperature)
      |> assign(:house, house)
      |> assign(:budeie, budeie_string)

    {:ok, reply_socket}
  end

  def handle_event("inc_temperature", _params, socket) do
    {:noreply, update(socket, :temperature, &(&1 + 1))}
  end
end
