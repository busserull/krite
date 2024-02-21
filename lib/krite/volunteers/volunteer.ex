defmodule Krite.Volunteers.Volunteer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "volunteers" do
    field :name, :string
    field :phone, :string
    field :checked_out, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @phone ~r/^\d{3}[\s-.]?\d{2}[\s-.]?\d{3}$/

  @doc false
  def changeset(volunteer, attrs) do
    volunteer
    |> cast(attrs, [:name, :phone, :checked_out])
    |> validate_required([:name, :phone])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_format(:phone, @phone, message: "must be a valid phone number")
  end
end
