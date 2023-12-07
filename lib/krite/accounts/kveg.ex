defmodule Krite.Accounts.Kveg do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Accounts.Deposit
  alias Krite.Purchases.Purchase

  schema "kveg" do
    field :active, :boolean, default: true
    field :firstname, :string
    field :lastname, :string
    field :subtitle, :string
    field :email, :string
    field :sauna_pass_end, :naive_datetime

    field :balance, :integer, default: 0, virtual: true

    has_many :deposits, Deposit
    has_many :purchases, Purchase

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(kveg, attrs) do
    kveg
    |> cast(attrs, [:active, :firstname, :lastname, :subtitle, :email, :sauna_pass_end])
    |> validate_required([
      :active,
      :firstname,
      :lastname,
      :email
    ])
  end
end
