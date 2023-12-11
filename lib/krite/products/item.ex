defmodule Krite.Products.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Products.Stock
  alias Krite.Products.Barcode
  alias Krite.Purchases.PurchaseItem

  schema "items" do
    field :active, :boolean, default: true
    field :name, :string
    field :price, :integer

    has_many :barcodes, Barcode

    has_many :purchases, PurchaseItem
    has_many :stocks, Stock

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:active, :name, :price])
    |> validate_required([:active, :name, :price])
  end
end
