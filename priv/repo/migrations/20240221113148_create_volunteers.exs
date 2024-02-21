defmodule Krite.Repo.Migrations.CreateVolunteers do
  use Ecto.Migration

  def change do
    create table(:volunteers) do
      add :name, :string
      add :phone, :string
      add :checked_out, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
