defmodule KriteWeb.CandyLive.FormComponent do
  use KriteWeb, :live_component

  alias Krite.Candyshop

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage candy records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="candy-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:calories]} type="number" label="Calories" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Candy</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{candy: candy} = assigns, socket) do
    changeset = Candyshop.change_candy(candy)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"candy" => candy_params}, socket) do
    changeset =
      socket.assigns.candy
      |> Candyshop.change_candy(candy_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"candy" => candy_params}, socket) do
    save_candy(socket, socket.assigns.action, candy_params)
  end

  defp save_candy(socket, :edit, candy_params) do
    case Candyshop.update_candy(socket.assigns.candy, candy_params) do
      {:ok, candy} ->
        notify_parent({:saved, candy})

        {:noreply,
         socket
         |> put_flash(:info, "Candy updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_candy(socket, :new, candy_params) do
    case Candyshop.create_candy(candy_params) do
      {:ok, candy} ->
        notify_parent({:saved, candy})

        {:noreply,
         socket
         |> put_flash(:info, "Candy created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
