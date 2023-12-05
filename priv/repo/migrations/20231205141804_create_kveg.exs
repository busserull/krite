defmodule Krite.Repo.Migrations.CreateKveg do
  use Ecto.Migration

  def change do
    create table(:kveg) do
      add :active, :boolean, default: true, null: false
      add :firstname, :string, null: false
      add :lastname, :string, null: false
      add :subtitle, :string
      add :email, :string, null: false
      add :balance, :integer, default: 0, null: false
      add :sauna_pass_end, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
