defmodule KriteWeb.KvegLive do
  use KriteWeb, :live_view

  alias Krite.Accounts
  alias Krite.Products
  alias Krite.Purchases

  def mount(_params, session, socket) do
    kveg = Accounts.get_kveg!(session["kveg_id"])
    IO.puts(inspect(kveg, pretty: true))

    catalog =
      Products.list_items()

    socket =
      socket
      |> assign(:kveg_id, kveg.id)
      |> assign(:balance, kveg.balance)
      |> assign(:catalog, catalog)
      |> assign(:search_list, [])
      |> assign(:search, "")
      |> assign(:cart, %{})

    {:ok, socket}
  end

  def handle_event("search", %{"search" => ""}, socket) do
    {:noreply, assign(socket, :search_list, [])}
  end

  def handle_event("search", %{"search" => term}, socket) do
    {:ok, regex} = Regex.compile(term, [:caseless])

    search_list =
      socket.assigns.catalog
      |> Enum.filter(&Regex.match?(regex, &1.name))

    {:noreply, assign(socket, :search_list, search_list)}
  end

  def handle_event("add-item", %{"item-id" => id}, socket) do
    {item_id, ""} = Integer.parse(id)

    item =
      socket.assigns.catalog
      |> Enum.find(fn product -> product.id == item_id end)

    {:noreply, add_item_to_cart(socket, item)}
  end

  def handle_event("sub-item", %{"item-id" => id}, socket) do
    {item_id, ""} = Integer.parse(id)

    socket =
      case Map.get(socket.assigns.cart, item_id) do
        {_name, 1} ->
          update(socket, :cart, &Map.delete(&1, item_id))

        _ ->
          update(
            socket,
            :cart,
            &Map.update!(&1, item_id, fn {name, count} -> {name, count - 1} end)
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
      |> assign(:search, " ")
      |> assign(:cart, %{})

    {:noreply, socket}
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
