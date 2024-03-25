defmodule KriteWeb.ShopLive do
  use KriteWeb, :live_view

  alias Phoenix.LiveView.JS
  alias KriteWeb.ShopLive.Products

  def mount(_params, _session, socket) do
    {:ok, assign(socket, products: Products.list_products(), cart: %{}, show_cart: false)}
  end

  def handle_event("add-product", %{"product" => product}, socket) do
    cart = Map.update(socket.assigns.cart, product, 1, &(&1 + 1))
    {:noreply, assign(socket, :cart, cart)}
  end

  def toggle_cart do
    JS.toggle(
      to: "#cart",
      in: {"ease-in-out duration-300", "translate-x-full", "translate-x-0"},
      out: {
        "ease-in-out duration-300",
        "translate-x-0",
        "translate-x-full"
      },
      time: 300
    )
    |> JS.toggle(to: "#backdrop", in: "fade-in", out: "fade-out")
  end
end
