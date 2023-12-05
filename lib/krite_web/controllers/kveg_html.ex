defmodule KriteWeb.KvegHTML do
  use KriteWeb, :html

  embed_templates "kveg_html/*"

  @doc """
  Renders a kveg form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def kveg_form(assigns)
end
