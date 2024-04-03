defmodule Krite.Repo.Migrations.AddUniqueConstraintKvegEmail do
  use Ecto.Migration

  def change do
    create unique_index(:kveg_accounts, [:email])
  end
end
