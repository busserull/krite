defmodule KriteWeb.VolunteerLive do
  use KriteWeb, :live_view

  alias Krite.Volunteers
  alias Krite.Volunteers.Volunteer
  alias KriteWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    {:ok, stream(socket, :volunteers, volunteers)}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>

    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} />

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

      <.link
        class="delete"
        data-confirm="Are you sure?"
        phx-click="delete-volunteer"
        phx-value-who={@volunteer.id}
      >
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end

  def handle_event("delete-volunteer", %{"who" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, volunteer} = Volunteers.delete_volunteer(volunteer)

    {:noreply, stream_delete(socket, :volunteers, volunteer)}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} =
      Volunteers.update_volunteer(
        volunteer,
        %{checked_out: !volunteer.checked_out}
      )

    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end
end
