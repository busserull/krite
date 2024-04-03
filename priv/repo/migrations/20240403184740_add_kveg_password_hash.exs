defmodule Krite.Repo.Migrations.AddKvegPasswordHash do
  use Ecto.Migration

  def change do
    alter table(:kveg_accounts) do
      add :password_hash, :string
    end
  end
end
