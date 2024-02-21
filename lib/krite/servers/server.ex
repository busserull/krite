defmodule Krite.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string
    field :size, :float
    field :status, :string, default: "down"
    field :deploy_count, :integer, default: 0
    field :framework, :string
    field :last_commit_message, :string

    timestamps(type: :utc_datetime)
  end

  @server_name ~r/^[a-z]+-[a-z]+$/

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :status, :deploy_count, :size, :framework, :last_commit_message])
    |> validate_required([:name, :size, :framework])
    |> validate_length(:name, min: 5)
    |> validate_format(:name, @server_name, message: "needs to be a valid server name")
    |> validate_number(:size, greater_than_or_equal_to: 0.0)
  end
end
