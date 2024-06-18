defmodule KriteWeb.TestLive do
  use KriteWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-[300px] h-[300px] bg-nat-100">
      <video autoplay></video>
    </div>

    <pre id="DebugPre" class="mt-2">
    </pre>

    <script src="/assets/test.js">
    </script>
    """
  end
end
