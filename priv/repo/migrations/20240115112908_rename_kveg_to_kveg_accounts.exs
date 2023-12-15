defmodule Krite.Repo.Migrations.RenameKvegToKvegAccounts do
  use Ecto.Migration

  def change do
    rename table(:kveg), to: table(:kveg_accounts)
  end
end
