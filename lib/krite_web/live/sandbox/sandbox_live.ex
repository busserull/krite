defmodule KriteWeb.SandboxLive do
  use KriteWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        length: "2",
        width: "4",
        depth: "6",
        weight: calculate_weight("2", "4", "6"),
        price: nil
      )

    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect(assigns, label: "ASSIGNS")

    ~H"""
    <div id="sandbox">
      <form phx-change="calculate" phx-submit="get-quote">
        <div class="fields">
          <label for="length">Length</label>
          <div class="input">
            <input type="number" name="length" value={@length} />
            <span class="unit">Meters</span>
          </div>

          <label for="width">Width</label>
          <div class="input">
            <input type="number" name="width" value={@width} />
            <span class="unit">Meters</span>
          </div>

          <label for="depth">Depth</label>
          <div class="input">
            <input type="number" name="depth" value={@depth} />
            <span class="unit">Meters</span>
          </div>

          <div class="weight" style="margin: 15px 0px;">
            You need <%= @weight %> kilograms of sand
          </div>

          <button
            type="submit"
            style="border: 1px solid #ececec; padding: 15px; border-radius: 100000px; margin: 10px;"
          >
            Get a Quote
          </button>

          <div :if={@price} class="quote">
            Get your personal beach today for only $<%= @price %>
          </div>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("calculate", params, socket) do
    %{"length" => l, "width" => w, "depth" => d} = params

    weight = calculate_weight(l, w, d)

    {:noreply, assign(socket, length: l, width: w, depth: d, weight: weight, price: nil)}
  end

  def handle_event("get-quote", _, socket) do
    price = calculate_price(socket.assigns.weight)
    {:noreply, assign(socket, price: price)}
  end

  defp calculate_weight(l, w, d) do
    (to_float(l) * to_float(w) * to_float(d) * 7.3) |> Float.round(1)
  end

  defp to_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> 0.0
    end
  end

  defp to_float(value), do: value

  defp calculate_price(weight) do
    (weight * 0.15) |> Float.round(2)
  end
end
