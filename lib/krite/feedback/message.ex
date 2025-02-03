defmodule Krite.Feedback.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :active, :boolean, default: false
    field :public, :boolean, default: false
    field :text, :string
    field :mood, :string
    field :seen_by, :id
    field :seconded_by, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:mood, :text, :active, :public])
    |> validate_required([:mood, :text, :active, :public])
  end
end
