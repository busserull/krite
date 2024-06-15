defmodule KriteWeb.KvegHTML do
  use KriteWeb, :html

  embed_templates "kveg_html/*"

  attr :balance, :integer, required: true

  def money_card(assigns) do
    ~H"""
    <div class={[
      (@balance < 0 && "from-orange-400 to-pink-600") || "from-teal-400 to-blue-600",
      "text-teal-50 bg-gradient-to-br rounded-md font-semibold p-6 w-full sm:w-auto
    flex flex-row justify-around"
    ]}>
      <div>
        <div class="text-base">
          Your account:
        </div>

        <div class="text-7xl">
          <%= @balance %> kr
        </div>

        <div :if={@balance < 0}>
          You might want to top that up
        </div>
      </div>
    </div>
    """
  end

  attr :rest, :global

  def sauna_pass_reminder(assigns) do
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

  attr :primary, :boolean, default: true
  attr :to, :any, required: true, doc: "the path to access when clicked"

  slot :inner_block, required: true

  def action(assigns) do
    ~H"""
    <a
      href={@to}
      class={[
        (@primary && "bg-blue-600 text-blue-50 hover:bg-blue-500") ||
          "border-2 border-blue-600 text-blue-600 hover:text-blue-400 hover:border-blue-400",
        "px-6 py-4 rounded-full text-xl font-semibold flex flex-row gap-2
        justify-center items-center hover:cursor-pointer transition-colors"
      ]}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  slot :inner_block, required: true

  def split(assigns) do
    ~H"""
    <div class="w-full flex flex-row justify-around gap-8 my-4 relative">
      <div class="border-b border-nat-500 h-[1px] absolute top-1/2 w-full left-0"></div>

      <div class="bg-main-bg relative px-5 font-medium text-lg text-stone-600 uppercase">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
