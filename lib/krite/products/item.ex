defmodule Krite.Products.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :active, :boolean, default: true
    field :name, :string
    field :barcode, :string
    field :price, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:active, :name, :barcode, :price])
    |> validate_required([:active, :name, :price])
  end
end
