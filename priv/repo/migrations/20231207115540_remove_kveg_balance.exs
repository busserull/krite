defmodule Krite.Repo.Migrations.RemoveKvegBalance do
  use Ecto.Migration

  def change do
    alter table(:kveg) do
      remove :balance, :integer, default: 0
    end
  end
end
