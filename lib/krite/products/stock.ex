defmodule Krite.Products.Stock do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Products.Item

  schema "stocks" do
    field :count, :integer
    belongs_to :item, Item

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, [:count])
    |> validate_required([:count])
    |> validate_number(:count, greater_than_or_equal_to: 0)
  end
end
