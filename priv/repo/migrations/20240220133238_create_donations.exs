defmodule Krite.Repo.Migrations.CreateDonations do
  use Ecto.Migration

  def change do
    create table(:donations) do
      add :item, :string
      add :emoji, :string
      add :quantity, :integer
      add :days_until_expires, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
