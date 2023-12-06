defmodule Krite.Accounts.Deposit do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Accounts.Kveg

  schema "deposits" do
    field :source, :string
    field :amount, :integer

    belongs_to :kveg, Kveg

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(deposit, attrs) do
    deposit
    |> cast(attrs, [:amount, :source])
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than: 0)
  end
end
