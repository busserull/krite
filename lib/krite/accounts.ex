defmodule Krite.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo
  alias Krite.Accounts.Kveg
  alias Krite.Accounts.Budeie

  @doc """
  Gets a single budeie.

  Raises `Ecto.NoResultsError` if the Budeie does not exist.
  """
  def get_budeie!(id), do: Repo.get!(Budeie, id)

  def get_budeie_by_email_and_password(email, password) when is_binary(email) do
    budeie = Repo.get_by(Budeie, email: email)
    if Budeie.valid_password?(budeie, password), do: budeie
  end

  def get_budeie_by_email_and_password(_, _), do: nil

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
  def get_kveg!(id), do: Kveg |> Repo.get!(id) |> calculate_and_put_balance()

  @doc """
  Get a single kveg by email and password, returning nil if no such kveg exists.

  ## Examples

    iex> get_kveg_by_email_and_password("kveg@example.com", "correct_password")
    %Kveg{}

    iex> get_kveg_by_email_and_password("kveg@example.com", "wrong_password")
    nil

    iex> get_kveg_by_email_and_password(123, 456)
    nil
  """
  def get_kveg_by_email_and_password(email, password) when is_binary(email) do
    kveg = Repo.get_by(Kveg, email: email)
    if Kveg.valid_password?(kveg, password), do: kveg
    end

  def get_kveg_by_email_and_password(_, _), do: nil

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

  defp calculate_and_put_balance(kveg) do
    kveg = Repo.preload(kveg, [:deposits, purchases: [:items]])

    deposits =
      kveg
      |> Map.fetch!(:deposits)
      |> Enum.map(&Map.fetch!(&1, :amount))
      |> Enum.sum()

    spending =
      kveg
      |> Map.fetch!(:purchases)
      |> Enum.map(&Map.fetch!(&1, :items))
      |> List.flatten()
      |> Enum.map(&(&1.unit_price_at_purchase * &1.count))
      |> Enum.sum()

    Map.put(kveg, :balance, deposits - spending)
  end
end
