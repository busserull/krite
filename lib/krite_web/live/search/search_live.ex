defmodule KriteWeb.SearchLive do
  use KriteWeb, :live_view

  alias KriteWeb.SearchLive.Flights

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        airport: "",
        flights: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a flight</h1>

    <form phx-submit="search">
      <input
        type="text"
        name="airport"
        value={@airport}
        placeholder="Airport Code"
        autofocus
        autocomplete="off"
        readonly={@loading}
      />

      <button>
        Search
      </button>
    </form>

    <div :if={@loading} class="loader">Loading...</div>

    <ul>
      <li :for={flight <- @flights}>
        Flight #<%= flight.number %>
        <%= flight.origin %> to <%= flight.destination %> Departs: <%= flight.departure_time %> Arrives: <%= flight.arrival_time %>
      </li>
    </ul>
    """
  end

  def handle_event("search", %{"airport" => airport}, socket) do
    send(self(), {:run_search, airport})

    socket =
      assign(
        socket,
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_info({:run_search, airport}, socket) do
    flights = Flights.search_by_airport(airport)

    socket =
      assign(
        socket,
        flights: flights,
        loading: false
      )

    {:noreply, socket}
  end
end
