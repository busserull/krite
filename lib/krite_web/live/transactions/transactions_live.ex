defmodule KriteWeb.TransactionsLive do
  use KriteWeb, :live_view

  alias Krite.Accounts

  def mount(_params, session, socket) do
    # if connected?(socket) do
    # end

    kveg =
      session["kveg_id"]
      |> Accounts.get_kveg!()
      |> Accounts.load_kveg_transactions()

    sorted =
      (kveg.deposits ++ kveg.purchases)
      |> Enum.sort(&NaiveDateTime.before?(&2.inserted_at, &1.inserted_at))
      |> group_by_month()

    months = get_selectable_months(sorted)

    socket =
      socket
      |> assign(kveg: kveg)
      |> assign(sorted: Map.new(sorted))
      |> assign(months: months)

    {:ok, socket}
  end

  attr(:months, :map, required: true)

  defp month_selection(assigns) do
    ~H"""
    <div class="flex flex-row bg-blue-50 justify-between" :if={@months.selected}>
    <div :if={@months.earlier != []}>
      <.icon name="hero-chevron-left-solid" />
    </div>

    <div>
    <%= inspect @months.selected %>
    </div>

    <div :if={@months.later != []}>
    <.icon name="hero-chevron-right-solid" />
    </div>
    </div>
    """
  end

  defp group_by_month(transactions) do
    group_by_month([], transactions)
  end

  defp group_by_month(acc, []), do: Enum.reverse(acc)

  defp group_by_month(acc, [head | _] = transactions) do
    year = head.inserted_at.year
    month = head.inserted_at.month

    {same_month, later} =
      Enum.split_while(transactions, fn x ->
        x.inserted_at.year == year && x.inserted_at.month == month
      end)

    group_by_month([{{year, month}, same_month} | acc], later)
  end

  defp get_selectable_months([]), do: %{earlier: [], selected: nil, later: []}

  defp get_selectable_months(list) do
    months = Enum.map(list, fn {time, _} -> time end)

    %{
      earlier: tl(months),
      selected: hd(months),
      later: []
    }
  end
end
