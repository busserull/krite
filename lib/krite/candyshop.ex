defmodule Krite.Candyshop do
  @moduledoc """
  The Candyshop context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo

  alias Krite.Candyshop.Candy

  @doc """
  Returns the list of candies.

  ## Examples

      iex> list_candies()
      [%Candy{}, ...]

  """
  def list_candies do
    Repo.all(Candy)
  end

  @doc """
  Gets a single candy.

  Raises `Ecto.NoResultsError` if the Candy does not exist.

  ## Examples

      iex> get_candy!(123)
      %Candy{}

      iex> get_candy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_candy!(id), do: Repo.get!(Candy, id)

  @doc """
  Creates a candy.

  ## Examples

      iex> create_candy(%{field: value})
      {:ok, %Candy{}}

      iex> create_candy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_candy(attrs \\ %{}) do
    %Candy{}
    |> Candy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a candy.

  ## Examples

      iex> update_candy(candy, %{field: new_value})
      {:ok, %Candy{}}

      iex> update_candy(candy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_candy(%Candy{} = candy, attrs) do
    candy
    |> Candy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a candy.

  ## Examples

      iex> delete_candy(candy)
      {:ok, %Candy{}}

      iex> delete_candy(candy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_candy(%Candy{} = candy) do
    Repo.delete(candy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking candy changes.

  ## Examples

      iex> change_candy(candy)
      %Ecto.Changeset{data: %Candy{}}

  """
  def change_candy(%Candy{} = candy, attrs \\ %{}) do
    Candy.changeset(candy, attrs)
  end
end
