defmodule Krite.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :mood, :string
      add :text, :text
      add :active, :boolean, default: true, null: false
      add :public, :boolean, default: false, null: false
      add :seen_by, references(:budeie_accounts, on_delete: :nothing)
      add :seconded_by, references(:kveg_accounts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:seen_by])
    create index(:messages, [:seconded_by])
  end
end
