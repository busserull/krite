defmodule KriteWeb.PurchaseHTML do
  use KriteWeb, :html

  embed_templates "purchase_html/*"

  @doc """
  Renders a purchase form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def purchase_form(assigns)
end
