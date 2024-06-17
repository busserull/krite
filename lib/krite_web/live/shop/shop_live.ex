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
      |> assign(:search_list, [])
      |> assign(:search, "")
      # |> assign(:cart, [{1, "Kvikk-Lunsj", 2}, {3, "Melk", 3}])
      |> assign(:cart, %{1 => {"Kvikk-Lunsj", 2}, 3 => {"Melk", 3}})
      |> assign(:total, 0)

    socket =
      if connected?(socket) do
        catalog = Products.list_items()
        assign(socket, catalog: catalog, search_list: [])
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

    socket =
      socket
      |> add_item_to_cart(item)
      |> update(:total, &(&1 + item.price))

    {:noreply, socket}
  end

  def handle_event("sub-item", %{"item-id" => id}, socket) do
    item = get_item(socket, id)
    socket = update(socket, :total, &(&1 - item.price))

    case Map.get(socket.assigns.cart, item.id) do
      {_name, 1} ->
        update(socket, :cart, &Map.delete(&1, item.id))

      _ ->
        update(
          socket,
          :cart,
          &Map.update!(&1, item.id, fn {name, count} -> {name, count - 1} end)
        )
    end

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

  defp add_item_to_cart(socket, item) do
    # TODO: inline this
    default = {item.name, 1}

    update(
      socket,
      :cart,
      &Map.update(&1, item.id, default, fn {name, count} -> {name, count + 1} end)
    )
  end
end
