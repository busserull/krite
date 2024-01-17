defmodule Krite.Candyshop.Candy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "candies" do
    field :name, :string
    field :calories, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(candy, attrs) do
    candy
    |> cast(attrs, [:name, :calories])
    |> validate_required([:name, :calories])
  end
end
