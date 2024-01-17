defmodule KriteWeb.CandyLive.Show do
  use KriteWeb, :live_view

  alias Krite.Candyshop

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:candy, Candyshop.get_candy!(id))}
  end

  defp page_title(:show), do: "Show Candy"
  defp page_title(:edit), do: "Edit Candy"
end
