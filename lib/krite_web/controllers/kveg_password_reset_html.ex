defmodule KriteWeb.KvegPasswordResetHTML do
  use KriteWeb, :html

  embed_templates("kveg_password_reset_html/*")

  attr(:message, :any, required: true)

  def stop_message(assigns) do
    ~H"""
    <%= if message = success_message(@message) do %>
      <.success>
        <%= message %>
      </.success>
    <% end %>

    <%= if message = error_message(@message) do %>
      <.error>
        <%= message %>
      </.error>
    <% end %>
    """
  end

  def back_to_login(assigns) do
    ~H"""
    <div class="mt-4">
      <.href to={~p"/"}>
        Back to login
      </.href>
    </div>
    """
  end

  defp success_message({:success, message}), do: message

  defp success_message(_), do: nil

  defp error_message({:error, message}), do: message

  defp error_message(_), do: nil
end
