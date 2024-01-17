defmodule KriteWeb.CandyLive.Index do
  use KriteWeb, :live_view

  alias Krite.Candyshop
  alias Krite.Candyshop.Candy

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :candies, Candyshop.list_candies())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Candy")
    |> assign(:candy, Candyshop.get_candy!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Candy")
    |> assign(:candy, %Candy{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Candies")
    |> assign(:candy, nil)
  end

  @impl true
  def handle_info({KriteWeb.CandyLive.FormComponent, {:saved, candy}}, socket) do
    {:noreply, stream_insert(socket, :candies, candy)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    candy = Candyshop.get_candy!(id)
    {:ok, _} = Candyshop.delete_candy(candy)

    {:noreply, stream_delete(socket, :candies, candy)}
  end
end
