defmodule Krite.Repo.Migrations.CreateStocks do
  use Ecto.Migration

  def change do
    create table(:stocks) do
      add :count, :integer, null: false
      add :item_id, references(:items, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:stocks, [:item_id])
  end
end
