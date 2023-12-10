defmodule Krite.Repo.Migrations.CreateBarcodes do
  use Ecto.Migration

  def change do
    create table(:barcodes) do
      add :code, :string, size: 16
      add :item_id, references(:items, on_delete: :delete_all)
    end

    create index(:barcodes, [:item_id])
    create unique_index(:barcodes, [:code])

    alter table(:items) do
      remove :barcode, :string
    end
  end
end
