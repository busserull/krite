defmodule Krite.Donations.Donation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "donations" do
    field :item, :string
    field :emoji, :string
    field :quantity, :integer
    field :days_until_expires, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(donation, attrs) do
    donation
    |> cast(attrs, [:item, :emoji, :quantity, :days_until_expires])
    |> validate_required([:item, :emoji, :quantity, :days_until_expires])
  end
end
