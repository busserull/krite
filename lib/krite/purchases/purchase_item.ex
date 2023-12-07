defmodule Krite.Purchases.PurchaseItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Products.Item
  alias Krite.Purchases.Purchase

  schema "purchase_items" do
    field :unit_price_at_purchase, :integer
    field :count, :integer
    belongs_to :purchase, Purchase
    belongs_to :item, Item
  end

  @doc false
  def changeset(purchase_item, attrs) do
    purchase_item
    |> cast(attrs, [:unit_price_at_purchase, :count])
    |> validate_required([:unit_price_at_purchase, :count])
    |> validate_number(:unit_price_at_purchase, greater_than_or_equal_to: 0)
    |> validate_number(:count, greater_than: 0)
  end
end
