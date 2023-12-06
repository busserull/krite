defmodule Krite.Accounts.Kveg do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Accounts.Deposit

  schema "kveg" do
    field :active, :boolean, default: true
    field :balance, :integer
    field :firstname, :string
    field :lastname, :string
    field :subtitle, :string
    field :email, :string
    field :sauna_pass_end, :naive_datetime

    has_many :deposits, Deposit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(kveg, attrs) do
    kveg
    |> cast(attrs, [:active, :firstname, :lastname, :subtitle, :email, :balance, :sauna_pass_end])
    |> validate_required([
      :active,
      :firstname,
      :lastname,
      :email,
      :balance
    ])
  end
end
