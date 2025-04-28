defmodule KriteWeb.ShopLive do
  use KriteWeb, :live_view

  alias Krite.Accounts
  alias Krite.Products
  alias Krite.Purchases

  # kveg: %Krite.Accounts.Kveg{}
  # search: A string containing the current search term
  # search_list: [{item_id, item_name, item_price}, ...] filter from :catalog by :search
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

        socket
        |> assign(catalog: catalog)
        |> update_search_list()
      else
        socket
      end

    {:ok, socket}
  end

  def handle_event("nop", _params, socket) do
    # This is a placeholder event for "add-first-item".
    # Figure out a way to unfocus the input bar when the item is added,
    # so that it doesn't remain open after the cart is updated.
    {:noreply, socket}
  end

  def handle_event("search", %{"search" => ""}, socket) do
    socket =
      socket
      |> assign(search: "")
      |> update_search_list()

    {:noreply, socket}
  end

  def handle_event("search", %{"search" => term}, socket) do
    term = String.replace(term, ~w/( ) [ ] { } * . ^ $ ? + \\ |/, "")

    socket =
      socket
      |> assign(:search, term)
      |> update_search_list()

    {:noreply, socket}
  end

  def handle_event("add-first-item", _params, socket) do
    {:noreply, add_item(socket, List.first(socket.assigns.search_list))}
  end

  def handle_event("add-item", %{"item-id" => id}, socket) do
    {:noreply, add_item(socket, id)}
  end

  def handle_event("sub-item", %{"item-id" => id}, socket) do
    {:noreply, sub_item(socket, id)}
  end

  def handle_event("checkout", _params, socket) do
    kveg_id = socket.assigns.kveg.id
    cart = socket.assigns.cart

    {:ok, _purchase} = Purchases.create_purchase(kveg_id, cart)

    {:ok, tref} = :timer.send_after(1500, :hide_flash)

    socket =
      socket
      |> assign(:search, "")
      |> update_search_list()
      |> assign(:cart, [])
      |> assign(:total, 0)
      |> assign(:flash_success, true)
      |> assign(:flash_timeout, tref)

    {:noreply, socket}
  end

  def handle_event("hide-flash", _params, socket), do: hide_flash(socket)

  def handle_info(:hide_flash, socket), do: hide_flash(socket)

  defp hide_flash(socket) do
    :timer.cancel(socket.assigns.flash_timeout)
    {:noreply, assign(socket, flash_success: false, flash_timeout: nil)}
  end

  defp get_item(socket, item_id) when is_binary(item_id) do
    case Integer.parse(item_id) do
      {id, ""} -> get_item(socket, id)
      _ -> nil
    end
  end

  defp get_item(socket, item_id) do
    Enum.find(socket.assigns.catalog, &(&1.id == item_id))
  end

  defp add_item(socket, nil), do: socket

  defp add_item(socket, {item_id, _text, _price}), do: add_item(socket, item_id)

  defp add_item(socket, item_id) do
    item = get_item(socket, item_id)

    old_cart = socket.assigns.cart

    cart =
      case Enum.find_index(old_cart, fn {i, _count} -> i.id == item.id end) do
        nil -> [{item, 1} | old_cart]
        index -> List.update_at(old_cart, index, fn {i, count} -> {i, count + 1} end)
      end

    socket
    |> assign(:cart, cart)
    |> assign(:search, "")
    |> update_search_list()
    |> update(:total, &(&1 + item.price))
  end

  defp sub_item(socket, item_id) do
    item = get_item(socket, item_id)

    old_cart = socket.assigns.cart

    item_index = Enum.find_index(old_cart, fn {i, _count} -> i.id == item.id end)

    cart =
      case Enum.at(old_cart, item_index) do
        {_item, 1} -> List.delete_at(old_cart, item_index)
        {item, count} -> List.update_at(old_cart, item_index, fn _ -> {item, count - 1} end)
      end

    socket
    |> assign(:cart, cart)
    |> update(:total, &(&1 - item.price))
  end

  defp update_search_list(socket) do
    search_list =
      case socket.assigns.search do
        "" ->
          Enum.map(socket.assigns.catalog, &{&1.id, &1.name, &1.price})

        term ->
          regex = Regex.compile!("(" <> term <> ")", [:caseless])

          term = String.downcase(term)

          replacement = "<span class=\"font-semibold\">\\1</span>"

          socket.assigns.catalog
          |> Enum.filter(&String.contains?(String.downcase(&1.name), term))
          |> Enum.map(&{&1.id, Regex.replace(regex, &1.name, replacement), &1.price})
      end

    assign(socket, :search_list, search_list)
  end
end
