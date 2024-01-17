defmodule Krite.Repo.Migrations.CreateCandies do
  use Ecto.Migration

  def change do
    create table(:candies) do
      add :name, :string
      add :calories, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
