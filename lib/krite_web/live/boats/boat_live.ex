defmodule KriteWeb.BoatLive do
  use KriteWeb, :live_view

  alias Krite.Boats
  alias Krite.Boats.Boat

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", prices: []},
        boats: Boats.list_boats()
      )

    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def render(assigns) do
    ~H"""
    <style>
      .promo {
      width: 100%;
      height: 4em;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      color: white;
      background: linear-gradient(90deg, rgba(30, 231, 85, 1) 0%, rgba(23, 97, 233, 1) 100%);
      border-radius: 10px;
      margin: 15px 0;
      font: small-caps bold 1.2rem sans-serif;
      position: relative;
      }

      .legal {
      font: italic 0.7em sans-serif;
      position: absolute;
      right: 0;
      bottom: 0;
      padding-right: 10px;
      padding-bottom: 10px;
      }

      .expiration {
      color: black;
      font-size: 0.7em;
      }
    </style>

    <h1>Daily Boat Rentals</h1>

    <.promo expiration={2}>
      Save 25% on rentals
      <:legal>
        <.icon name="hero-exclamation-circle" /> Limit 1 per party
      </:legal>
    </.promo>

    <form phx-change="filter">
      <div class="filters">
        <select name="type">
          <%= Phoenix.HTML.Form.options_for_select(type_options(), @filter.type) %>
        </select>

        <div class="prices">
          <%= for price <- ["$", "$$", "$$$"] do %>
            <input
              type="checkbox"
              name="prices[]"
              value={price}
              id={price}
              checked={price in @filter.prices}
            />
            <label for={price}><%= price %></label>
          <% end %>
          <input type="hidden" name="prices[]" value="" />
        </div>
      </div>
    </form>

    <div
      id="boats"
      style="display: grid; grid-template-columns: repeat(4, 1fr); grid-template-rows: minmax(100px, auto); gap: 35px 15px"
    >
      <div :for={boat <- @boats} class="boat" style="border-bottom: 1px solid #cecece;">
        <img src={boat.image} />
        <div class="content">
          <div class="model">
            <%= boat.model %>
          </div>

          <div class="details">
            <span class="price">
              <%= boat.price %>
            </span>
            <span class="type"><%= boat.type %></span>
          </div>
        </div>
      </div>
    </div>

    <.promo expiration={1}>
      Hurry, only 3 boats left
      <:legal>
        Excluding weekends
      </:legal>
    </.promo>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter = %{type: type, prices: prices}
    boats = Boats.list_boats(filter)

    {:noreply, assign(socket, boats: boats, filter: filter)}
  end

  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>

      <div class="expiration">
        Deal expires in <%= @expiration %> hours
      </div>

      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end

  defp type_options do
    [
      "All types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
