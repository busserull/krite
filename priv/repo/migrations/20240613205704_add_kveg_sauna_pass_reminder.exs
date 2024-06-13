defmodule Krite.Repo.Migrations.AddKvegSaunaPassReminder do
  use Ecto.Migration

  def change do
    alter table(:kveg_accounts) do
      add :sauna_pass_reminder, :boolean, default: true
    end
  end
end
