defmodule Krite.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Products.Item

  schema "organizations" do
    field :name, :string
    has_many :items, Item

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
