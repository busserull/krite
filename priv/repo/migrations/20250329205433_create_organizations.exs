defmodule Krite.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    alter table(:items) do
      add :owner_id, references(:organizations, on_delete: :delete_all)
    end
  end
end
