defmodule KriteWeb.KvegHTML do
  use KriteWeb, :html

  embed_templates("kveg_html/*")

  attr(:balance, :integer, required: true)

  defp balance_card(assigns) do
    ~H"""
    <div class={["bg-gradient-to-br rounded-md pt-4 px-5 relative overflow-hidden shadow-lg shadow-black/40 w-full flex flex-col justify-between items-start",
    @balance < 0 && "from-amber-500 to-pink-600" || "from-green-500 to-teal-600"]}>
    <div>
    <p class={["font-semibold", @balance < 0 && "text-amber-900" || "text-green-800"]}>Your account</p>
    <p class={["font-semibold mt-1 mb-4", @balance < 0 && "text-amber-50" || "text-green-50"]}>
      <span class="text-6xl"><%= @balance %></span> <span class="text-2xl">kr</span>
    </p>
    </div>

    <.link href={~p"/kveg/account-top-up"} class={["border-t w-full hover:cursor-pointer", @balance < 0 && "border-amber-50/60" || "border-green-50/30"]}>
    <p class={["font-semibold text-center pt-2", @balance < 0 && "text-amber-50 text-xl pb-1" || "text-green-800 pb-3"]}>
      Click here to top it up
    </p>
    <p :if={@balance < 0} class="text-red-900 text-center text-semibold pb-3">
      (You should do that now)
    </p>
    </.link>
    </div>
    """
  end

  attr(:pass_end, :any, required: true)

  defp sauna_card(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-green-500 to-teal-600 rounded-md py-4 px-5 relative z-10 overflow-hidden shadow-lg shadow-black/40 w-full flex flex-col justify-between items-start">
    <img src={~p"/images/sauna_heat_lines.svg"} class="h-28 w-28 absolute -z-10 opacity-80 right-1 top-4" />

    <div>
    <p class="text-green-800 font-semibold">Sauna pass</p>
    <p class="text-4xl font-semibold tracking-wider text-green-50 mt-1">Valid</p>
    </div>

    <div>
    <p class="text-green-800 font-semibold mt-2">Expires</p>
    <p class="text-2xl font-semibold tracking-wide text-green-50">
      <%= format_expire_date(@pass_end) %>
    </p>
    </div>
    </div>
    """
  end

  attr(:rest, :global)

  defp sauna_pass_reminder(assigns) do
    ~H"""
    <div class="text-yellow-600 bg-yellow-100 border-yellow-600 border rounded-md
      flex flex-col sm:flex-row justify-between my-4">
      <div class="font-medium text-lg p-4">
        Oh no! You don't have a sauna pass.
      </div>

      <div class="grid grid-cols-2 border-t sm:border-none border-yellow-500">
        <.form
          for={%{}}
          action={~p"/kveg/sauna-pass-unremind"}
          method="post"
          class="flex flex-row justify-center items-center sm:border-l border-yellow-500"
        >
          <button class="h-full w-full p-4 underline underline-offset-4">
            Don't remind me
          </button>
        </.form>

        <a
          href={~p"/"}
          class="h-full p-4 underline underline-offset-4
          flex flex-row justify-center items-center border-l border-yellow-500"
        >
          Get one now
        </a>
      </div>
    </div>
    """
  end

  attr(:to, :any, required: true)
  attr(:class, :any, default: "")

  slot(:inner_block, required: true)

  defp action(assigns) do
    ~H"""
    <a href={@to} class={["border rounded-full border-blue-600 hover:bg-blue-500 text-blue-800 hover:text-white py-3 px-6 text-xl font-semibold transition-colors hover:cursor-pointer flex flex-row items-center justify-between shadow-md gap-3", @class]}>
      <p><%= render_slot(@inner_block) %></p>
      <.icon name="hero-chevron-right" class="h-6 w-6"/>
    </a>
    """
  end

  defp format_expire_date(date) do
    now = NaiveDateTime.utc_now()

    cond do
      NaiveDateTime.diff(date, now, :minute) < 5 * 60 ->
        "Later today"

      NaiveDateTime.diff(date, now, :hour) < 24 ->
        "Tomorrow"

      true ->
        Calendar.strftime(date, "%B %-d") <> ordinal(date.day) <> " #{date.year}"
    end
  end

  defp ordinal(number) do
    case number do
      1 -> "st"
      2 -> "nd"
      3 -> "rd"
      _ -> "th"
    end
  end
end
