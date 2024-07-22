defmodule Krite.Purchases.Purchase do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Accounts.Kveg
  alias Krite.Purchases.PurchaseItem

  schema "purchases" do
    belongs_to :kveg, Kveg
    has_many :items, PurchaseItem

    field :total_cost, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(purchase, attrs) do
    purchase
    |> cast(attrs, [])
    |> validate_required([])
  end
end
