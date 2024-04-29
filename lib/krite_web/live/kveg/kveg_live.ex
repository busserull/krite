defmodule KriteWeb.KvegLive do
  use KriteWeb, :live_view

  alias Krite.Accounts

  def mount(_params, session, socket) do
    kveg = Accounts.get_kveg!(session["kveg_id"])
    IO.puts(inspect(kveg, pretty: true))

    if connected?(socket) do
      :timer.send_interval(1000, self(), :add_some)
    end

    socket =
      socket
      |> assign(:balance, kveg.balance)
      |> assign(:cart, [])

    {:ok, socket}
  end

  def handle_event("add-random", _params, socket) do
    items = ~W(Juice Milk Beer Panties Oxygen)

    {:noreply, update(socket, :cart, &[Enum.random(items) | &1])}
  end

  def handle_info(:add_some, socket) do
    item = Enum.random(~W(Juice Milk Beer Panties Ketamine))

    {:noreply, update(socket, :cart, &[item | Enum.take(&1, 9)])}
  end
end
