defmodule KriteWeb.TransactionsLive do
  use KriteWeb, :live_view

  alias Krite.Accounts
  alias Krite.Accounts.Deposit
  alias Krite.Purchases.Purchase

  def mount(_params, session, socket) do
    # if connected?(socket) do
    # end

    kveg =
      session["kveg_id"]
      |> Accounts.get_kveg!()
      |> Accounts.load_kveg_transactions()

    transactions =
      (kveg.deposits ++ kveg.purchases)
      |> Enum.sort(&NaiveDateTime.before?(&2.inserted_at, &1.inserted_at))
      |> Enum.map(&Map.put(&1, :expanded, false))
      |> group_by_month()

    months = get_selectable_months(transactions)

    socket =
      socket
      |> assign(kveg: kveg)
      |> assign(transactions: Map.new(transactions))
      |> assign(months: months)

    {:ok, socket}
  end

  def handle_event("next-month", _params, socket) do
    %{selected: now, later: [next | rest], earlier: earlier} = socket.assigns.months

    {:noreply,
     assign(socket, :months, %{
       selected: next,
       later: rest,
       earlier: [now | earlier]
     })}
  end

  def handle_event("previous-month", _params, socket) do
    %{selected: now, later: later, earlier: [previous | rest]} = socket.assigns.months

    {:noreply,
     assign(socket, :months, %{
       selected: previous,
       later: [now | later],
       earlier: rest
     })}
  end

  def handle_event("toggle-details", %{"id" => id}, socket) do
    {id, ""} = Integer.parse(id)

    selected = socket.assigns.months.selected

    socket =
      update(
        socket,
        :transactions,
        &Map.update!(&1, selected, fn list ->
          Enum.map(list, fn entry ->
            case entry do
              %Purchase{id: ^id} ->
                Map.update!(entry, :expanded, fn x -> !x end)

              _ ->
                entry
            end
          end)
        end)
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.take_me_back to={~p"/kveg"} />

    <h1 class="text-3xl text-stone-600 mt-4">Your transaction history</h1>

    <section :if={false} class="flex flex-row gap-6">
      <.button>Deposits</.button>
      <.button>Purchases</.button>
    </section>

    <.month_selection months={@months} class="mt-10 mb-1" />

    <section>
      <ul>
        <%= for entry <- Map.fetch!(@transactions, @months.selected) do %>
          <li class="my-4 border-t border-stone-400 pt-3 first-of-type:border-none">
            <.purchase :if={is_purchase(entry)} entry={entry} />
            <.deposit :if={is_deposit(entry)} entry={entry} />
          </li>
        <% end %>
      </ul>
    </section>
    """
  end

  attr(:months, :map, required: true)
  attr(:class, :string, default: "")

  defp month_selection(assigns) do
    ~H"""
    <div class={["flex flex-row justify-center items-center", @class]} :if={@months.selected}>

    <div class={["h-8 w-8 rounded-full flex flex-row justify-center items-center transition-colors bg-blue-500 text-white hover:bg-blue-400",
    @months.earlier != [] && "hover:cursor-pointer" || "opacity-0"]} phx-click="previous-month">
    <.icon name="hero-chevron-left-solid" />
    </div>


    <div class="text-2xl w-60 text-center">
    <%= month_string(@months.selected) %>
    </div>

    <div class={["h-8 w-8 rounded-full flex flex-row justify-center items-center transition-colors bg-blue-500 text-white hover:bg-blue-400",
     @months.later != [] && "hover:cursor-pointer" || "opacity-0"]} phx-click="next-month">
    <.icon name="hero-chevron-right-solid" />
    </div>
    </div>
    """
  end

  attr(:entry, :map, required: true)

  defp transaction_entry(assigns) do
    ~H"""
    <%= inspect @entry %>
    """
  end

  attr(:entry, :map, required: true)

  defp purchase(assigns) do
    ~H"""
    <div class="flex flex-row justify-between items-center">
      <div>
        <p class="font-semibold text-blue-600">
          Purchase
        </p>

        <p class="text-stone-600 text-lg tracking-wide">
          <%= Calendar.strftime(@entry.inserted_at, "%d.%m %H:%M") %>
        </p>
      </div>

      <div class="flex flex-row items-center">
        <p class="text-stone-700 font-semibold">
          <span class="text-3xl font-normal"><%= @entry.total_cost %></span> kr
        </p>

        <div class="h-10 w-10 rounded-full flex justify-center items-center hover:cursor-pointer hover:bg-blue-500 hover:text-white ml-3 transition-colors"
        phx-click="toggle-details" phx-value-id={@entry.id}>
          <.icon :if={!@entry.expanded} name="hero-chevron-down-solid" />
          <.icon :if={@entry.expanded} name="hero-chevron-up-solid" />
        </div>
      </div>
    </div>

    <table :if={@entry.expanded} class="ml-auto text-right text-blue-600 mt-3 mb-8">
    <thead>
      <tr>
        <th class="py-1 pl-12">Item</th>
        <th class="py-1 pl-12">Unit price</th>
        <th class="py-1 pl-12">Count</th>
        <th class="py-1 pl-12">Subtotal</th>
      </tr>
    </thead>

    <tbody>
      <tr :for={item <- @entry.items} class="border-b border-stone-200 last-of-type:border-none">
        <th class="font-semibold text-stone-900 py-1"><%= item.item.name %></th>
        <th class="font-semibold text-stone-900 py-1"><%= item.unit_price_at_purchase %> kr</th>
        <th class="font-semibold text-stone-900 py-1"><%= item.count %></th>
        <th class="font-semibold text-stone-900 py-1"><%= item.unit_price_at_purchase * item.count %> kr</th>
      </tr>
    </tbody>
    </table>
    """
  end

  attr(:entry, :map, required: true)

  defp deposit(assigns) do
    ~H"""
    <div class="flex flex-row justify-between items-center">
      <div>
        <p class="font-semibold text-green-600">
          Deposit
        </p>

        <p class="text-stone-600 text-lg tracking-wide">
          <%= Calendar.strftime(@entry.inserted_at, "%d.%m %H:%M") %>
        </p>
      </div>

      <div class="flex flex-row items-center">
        <p class="text-stone-700 font-semibold">
          <span class="pb-2">+</span>
          <span class="text-3xl font-normal"><%= @entry.amount %></span> kr
        </p>

        <div class="h-10 w-10 ml-3 opacity-0">
        </div>
      </div>
    </div>
    """
  end

  defp is_purchase(%Purchase{}), do: true

  defp is_purchase(_), do: false

  defp is_deposit(%Deposit{}), do: true

  defp is_deposit(_), do: false

  defp month_string({year, month}) do
    NaiveDateTime.new!(year, month, 1, 0, 0, 0)
    |> Calendar.strftime("%B %Y")
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
