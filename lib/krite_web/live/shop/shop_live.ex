defmodule KriteWeb.ShopLive do
  use KriteWeb, :live_view

  alias Krite.Accounts
  alias Krite.Products

  # kveg: %Krite.Accounts.Kveg{}
  # search: A string containing the current search term
  # search_list: A filter of :catalog that fit :search
  # catalog: [%Krite.Products.Item{}, ...] with :barcodes preloaded
  # cart: [{%Krite.Products.Items{}, item_count}, ...]
  # total: The total cost of the :cart
  # flash_success: A flag that, when enabled, flashes a success message after a purchase
  # flash_timeout: A tref that counts down to setting :flash_success false

  def mount(_params, session, socket) do
    kveg = Accounts.get_kveg!(session["kveg_id"])

    socket =
      socket
      |> assign(:kveg, kveg)
      |> assign(:search, "")
      |> assign(:search_list, [])
      |> assign(:catalog, [])
      |> assign(:cart, [])
      |> assign(:total, 0)
      |> assign(:flash_success, false)
      |> assign(:flash_timeout, nil)

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
    {:noreply, assign(socket, search: "", search_list: socket.assigns.catalog)}
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

  def handle_event("add-first-item", _params, socket) do
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
      |> assign(:search, "")
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
    :timer.sleep(1000)
    # kveg_id = socket.assigns.kveg.id
    # cart = socket.assigns.cart

    # {:ok, purchase} = Purchases.create_purchase(kveg_id, cart)

    {:ok, tref} = :timer.send_after(3000, :hide_flash)

    socket =
      socket
      |> assign(:search_list, socket.assigns.catalog)
      |> assign(:search, "")
      |> assign(:cart, [])
      |> assign(:total, 0)
      |> assign(:flash_success, true)
      |> assign(:flash_timeout, tref)

    {:noreply, socket}
  end

  def handle_event("hide-flash", _params, socket) do
    hide_flash(socket)
  end

  def handle_info(:hide_flash, socket) do
    hide_flash(socket)
  end

  defp hide_flash(socket) do
    :timer.cancel(socket.assigns.flash_timeout)
    {:noreply, assign(socket, flash_success: false, flash_timeout: nil)}
  end

  defp get_item(socket, item_id) do
    case Integer.parse(item_id) do
      {id, ""} -> Enum.find(socket.assigns.catalog, &(&1.id == id))
      _ -> nil
    end
  end
end
