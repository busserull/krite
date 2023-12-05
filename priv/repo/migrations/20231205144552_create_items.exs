defmodule Krite.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :active, :boolean, default: true, null: false
      add :name, :string, null: false
      add :barcode, :string
      add :price, :integer, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
