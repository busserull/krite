defmodule KriteWeb.VolunteerLive do
  use KriteWeb, :live_view

  alias Krite.Volunteers
  alias Krite.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    form = to_form(changeset)

    email_form = to_form(%{"email" => ""})

    socket =
      assign(socket,
        volunteers: volunteers,
        form: form,
        email_form: email_form
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>

    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000" />
        <.input
          field={@form[:phone]}
          placeholder="Phone"
          autocomplete="off"
          type="tel"
          phx-debounce="blur"
        />

        <.button phx-disable-with="Saving...">
          Check In
        </.button>
      </.form>

      <div :for={volunteer <- @volunteers} class={"volunteer #{if volunteer.checked_out, do: "out"}"}>
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket =
          socket
          |> update(:volunteers, &[volunteer | &1])
          |> assign(:form, to_form(changeset))
          |> put_flash(:info, "Success!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
