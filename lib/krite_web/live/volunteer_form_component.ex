defmodule KriteWeb.VolunteerFormComponent do
  use KriteWeb, :live_component

  alias Krite.Volunteers
  alias Krite.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
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
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})

        send(self(), {:volunteer_created, volunteer})

        socket =
          socket
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
