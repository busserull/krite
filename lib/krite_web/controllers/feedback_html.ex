defmodule KriteWeb.FeedbackHTML do
  use KriteWeb, :html

  embed_templates("feedback_html/*")

  @doc """
  Renders a message form.
  """
  attr(:changeset, Ecto.Changeset, required: true)
  attr(:action, :string, required: true)

  def message_form(assigns)
end
