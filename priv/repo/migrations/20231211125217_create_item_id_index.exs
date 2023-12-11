defmodule Krite.Repo.Migrations.CreateItemIdIndex do
  use Ecto.Migration

  def change do
    create index(:purchase_items, [:item_id])
  end
end
