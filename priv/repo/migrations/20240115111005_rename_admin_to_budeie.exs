defmodule Krite.Repo.Migrations.RenameAdminToBudeie do
  use Ecto.Migration

  def change do
    rename table(:admins), to: table(:budeie_accounts)
  end
end
