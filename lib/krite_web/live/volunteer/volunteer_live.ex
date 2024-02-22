defmodule KriteWeb.VolunteerLive do
  use KriteWeb, :live_view

  alias Krite.Volunteers
  alias Krite.Volunteers.Volunteer
  alias KriteWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, stream(socket, :volunteers, volunteers)}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>

    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} count={@count} />

      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={volunteer_id}
        />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div class={"volunteer #{if @volunteer.checked_out, do: "out"}"} id={@id}>
      <div class="name">
        <%= @volunteer.name %>
      </div>

      <div class="phone">
        <%= @volunteer.phone %>
      </div>

      <div class="status">
        <button phx-click="toggle-status" phx-value-id={@volunteer.id}>
          <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
        </button>
      </div>

      <.link class="delete" phx-click="delete-volunteer" phx-value-who={@volunteer.id}>
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end

  def handle_event("delete-volunteer", %{"who" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, volunteer} = Volunteers.delete_volunteer(volunteer)

    socket =
      socket
      |> stream_delete(:volunteers, volunteer)
      |> update(:count, &(&1 - 1))

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    Volunteers.update_volunteer(
      volunteer,
      %{checked_out: !volunteer.checked_out}
    )

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket =
      socket
      |> stream_insert(:volunteers, volunteer, at: 0)
      |> update(:count, &(&1 + 1))

    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end
end
