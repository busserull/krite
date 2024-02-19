defmodule KriteWeb.SalesLive do
  use KriteWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign_stats(socket)}
  end

  def render(assigns) do
    ~H"""
    <h1>Snappy Sales</h1>

    <div id="sales">
      New orders: <%= @new_orders %>
    </div>

    <div id="amount">
      Sales amount: $<%= @sales_amount %>
    </div>

    <div id="satisfaction">
      Customer satisfaction: <%= @satisfaction %>%
    </div>

    <button phx-click="refresh">
      Refresh
    </button>
    """
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: new_orders(),
      sales_amount: sales_amount(),
      satisfaction: satisfaction()
    )
  end

  defp new_orders(), do: Enum.random(5..20)
  defp sales_amount(), do: Enum.random(100..1000)
  defp satisfaction(), do: Enum.random(95..100)
end
