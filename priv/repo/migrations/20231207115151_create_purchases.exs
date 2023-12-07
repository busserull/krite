defmodule Krite.Repo.Migrations.CreatePurchases do
  use Ecto.Migration

  def change do
    create table(:purchases) do
      add :kveg_id, references(:kveg, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
