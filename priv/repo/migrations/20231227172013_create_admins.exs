defmodule Krite.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :email, :string
      add :password_hash, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:admins, [:email])
  end
end
