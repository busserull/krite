defmodule Krite.Volunteers do
  @moduledoc """
  The Volunteers context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo

  alias Krite.Volunteers.Volunteer

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Krite.PubSub, @topic)
  end

  def broadcast({:ok, volunteer}, event) do
    Phoenix.PubSub.broadcast(Krite.PubSub, @topic, {event, volunteer})
    {:ok, volunteer}
  end

  def broadcast({:error, _changeset} = error, _event), do: error

  @doc """
  Returns the list of volunteers.

  ## Examples

      iex> list_volunteers()
      [%Volunteer{}, ...]

  """
  def list_volunteers do
    Repo.all(from v in Volunteer, order_by: [desc: v.id])
  end

  @doc """
  Gets a single volunteer.

  Raises `Ecto.NoResultsError` if the Volunteer does not exist.

  ## Examples

      iex> get_volunteer!(123)
      %Volunteer{}

      iex> get_volunteer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_volunteer!(id), do: Repo.get!(Volunteer, id)

  @doc """
  Creates a volunteer.

  ## Examples

      iex> create_volunteer(%{field: value})
      {:ok, %Volunteer{}}

      iex> create_volunteer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_volunteer(attrs \\ %{}) do
    {:ok, volunteer} =
      %Volunteer{}
      |> Volunteer.changeset(attrs)
      |> Repo.insert()
      |> broadcast(:volunteer_created)
  end

  @doc """
  Updates a volunteer.

  ## Examples

      iex> update_volunteer(volunteer, %{field: new_value})
      {:ok, %Volunteer{}}

      iex> update_volunteer(volunteer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_volunteer(%Volunteer{} = volunteer, attrs) do
    {:ok, volunteer} =
      volunteer
      |> Volunteer.changeset(attrs)
      |> Repo.update()
      |> broadcast(:volunteer_updated)
  end

  @doc """
  Deletes a volunteer.

  ## Examples

      iex> delete_volunteer(volunteer)
      {:ok, %Volunteer{}}

      iex> delete_volunteer(volunteer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_volunteer(%Volunteer{} = volunteer) do
    volunteer
    |> Repo.delete()
    |> broadcast(:volunteer_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking volunteer changes.

  ## Examples

      iex> change_volunteer(volunteer)
      %Ecto.Changeset{data: %Volunteer{}}

  """
  def change_volunteer(%Volunteer{} = volunteer, attrs \\ %{}) do
    Volunteer.changeset(volunteer, attrs)
  end
end
