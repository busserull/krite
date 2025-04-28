defmodule Krite.Repo.Migrations.CreatePurchaseItems do
  use Ecto.Migration

  def change do
    create table(:purchase_items) do
      add :unit_price_at_purchase, :integer, null: false
      add :count, :integer, null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
      add :purchase_id, references(:purchases, on_delete: :delete_all), null: false
    end

    create index(:purchase_items, [:purchase_id])
  end
end
