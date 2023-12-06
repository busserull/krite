defmodule Krite.Repo.Migrations.CreateDeposits do
  use Ecto.Migration

  def change do
    create table(:deposits) do
      add :amount, :integer, null: false
      add :source, :string
      add :kveg_id, references(:kveg, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:deposits, [:kveg_id])
  end
end
