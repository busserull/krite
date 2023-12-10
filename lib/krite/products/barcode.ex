defmodule Krite.Products.Barcode do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Products.Item

  schema "barcodes" do
    field :code, :string
    belongs_to :item, Item
  end

  @doc false
  def changeset(barcode, attrs) do
    barcode
    |> cast(attrs, [:code])
    |> validate_required([:code])
  end
end
