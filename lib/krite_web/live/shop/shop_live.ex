defmodule KriteWeb.ShopLive do
  use KriteWeb, :live_view

  alias Krite.Accounts
  alias Krite.Products
  alias Krite.Purchases

  def mount(_params, session, socket) do
    kveg = Accounts.get_kveg!(session["kveg_id"])

    socket =
      socket
      |> assign(:kveg, kveg)
      |> assign(:search_list, [
        %{id: 1, name: "Smooth talker", price: 200},
        %{id: 2, name: "Womanizer", price: 90000}
      ])
      |> assign(:search, "")
      |> assign(:cart, [])
      |> assign(:total, 0)

    socket =
      if connected?(socket) do
        catalog = Products.list_items()
        assign(socket, catalog: catalog, search_list: catalog)
      else
        socket
      end

    {:ok, socket}
  end

  def handle_event("search", %{"search" => ""}, socket) do
    {:noreply, assign(socket, search: "", search_list: [])}
  end

  def handle_event("search", %{"search" => term}, socket) do
    {:ok, regex} = Regex.compile(term, [:caseless])

    search_list =
      socket.assigns.catalog
      |> Enum.filter(&Regex.match?(regex, &1.name))

    socket =
      socket
      |> assign(:search_list, search_list)
      |> assign(:search, term)

    {:noreply, socket}
  end

  def handle_event("add-item", %{"item-id" => id}, socket) do
    item = get_item(socket, id)

    old_cart = socket.assigns.cart

    cart =
      case Enum.find_index(old_cart, fn {i, _count} -> i.id == item.id end) do
        nil -> [{item, 1} | old_cart]
        index -> List.update_at(old_cart, index, fn {i, count} -> {i, count + 1} end)
      end

    socket =
      socket
      |> assign(:cart, cart)
      |> update(:total, &(&1 + item.price))

    {:noreply, socket}
  end

  def handle_event("sub-item", %{"item-id" => id}, socket) do
    item = get_item(socket, id)

    old_cart = socket.assigns.cart

    item_index = Enum.find_index(old_cart, fn {i, _count} -> i.id == item.id end)

    cart =
      case Enum.at(old_cart, item_index) do
        {_item, 1} -> List.delete_at(old_cart, item_index)
        {item, count} -> List.update_at(old_cart, item_index, fn _ -> {item, count - 1} end)
      end

    socket =
      socket
      |> assign(:cart, cart)
      |> update(:total, &(&1 - item.price))

    {:noreply, socket}
  end

  def handle_event("checkout", _params, socket) do
    cart = Map.new(socket.assigns.cart, fn {id, {_name, count}} -> {id, count} end)

    {:ok, purchase} = Purchases.create_purchase(socket.assigns.kveg_id, cart)

    socket =
      socket
      |> update(:balance, &(&1 - purchase.total_cost))
      |> assign(:search_list, [])
      |> assign(:search, "")
      |> assign(:cart, %{})

    {:noreply, socket}
  end

  defp get_item(socket, item_id) do
    case Integer.parse(item_id) do
      {id, ""} -> Enum.find(socket.assigns.catalog, &(&1.id == id))
      _ -> nil
    end
  end
end
