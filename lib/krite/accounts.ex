defmodule Krite.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo

  alias Krite.Accounts.Kveg

  @doc """
  Returns the list of kveg.

  ## Examples

      iex> list_kveg()
      [%Kveg{}, ...]

  """
  def list_kveg do
    Repo.all(Kveg)
  end

  @doc """
  Gets a single kveg.

  Raises `Ecto.NoResultsError` if the Kveg does not exist.

  ## Examples

      iex> get_kveg!(123)
      %Kveg{}

      iex> get_kveg!(456)
      ** (Ecto.NoResultsError)

  """
  def get_kveg!(id), do: Repo.get!(Kveg, id)

  @doc """
  Creates a kveg.

  ## Examples

      iex> create_kveg(%{field: value})
      {:ok, %Kveg{}}

      iex> create_kveg(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_kveg(attrs \\ %{}) do
    %Kveg{}
    |> Kveg.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a kveg.

  ## Examples

      iex> update_kveg(kveg, %{field: new_value})
      {:ok, %Kveg{}}

      iex> update_kveg(kveg, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_kveg(%Kveg{} = kveg, attrs) do
    kveg
    |> Kveg.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a kveg.

  ## Examples

      iex> delete_kveg(kveg)
      {:ok, %Kveg{}}

      iex> delete_kveg(kveg)
      {:error, %Ecto.Changeset{}}

  """
  def delete_kveg(%Kveg{} = kveg) do
    Repo.delete(kveg)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking kveg changes.

  ## Examples

      iex> change_kveg(kveg)
      %Ecto.Changeset{data: %Kveg{}}

  """
  def change_kveg(%Kveg{} = kveg, attrs \\ %{}) do
    Kveg.changeset(kveg, attrs)
  end
end
