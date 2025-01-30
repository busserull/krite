defmodule Krite.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo
  alias Krite.Accounts.Kveg
  alias Krite.Accounts.Budeie
  alias Krite.Purchases.Purchase

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
  def get_kveg!(id), do: Repo.get!(Kveg, id)

  def load_kveg_balance(%Kveg{} = kveg) do
    kveg =
      kveg
      |> Repo.preload([:deposits, purchases: [:items]])
      |> Map.update!(:purchases, &calculate_purchase_totals/1)

    deposits =
      kveg.deposits
      |> Enum.map(&Map.fetch!(&1, :amount))
      |> Enum.sum()

    spending =
      kveg.purchases
      |> Enum.map(&Map.fetch!(&1, :total_cost))
      |> Enum.sum()

    Map.put(kveg, :balance, deposits - spending)
  end

  def load_kveg_transactions(%Kveg{} = kveg) do
    Repo.preload(kveg, [:deposits, purchases: [items: [:item]]])
  end

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
  Get a Kveg from a password reset link handle.

  ## Examples
    
    # This link exists and has not expired
    iex> get_kveg_by_password_reset_link("c8ab2d39636383c71764df01146796d1")
    %Kveg{}

    # After some time, the link has expired, and cannot be used again
    iex> get_kveg_by_password_reset_link("c8ab2d39636383c71764df01146796d1")
    nil

    # This link does not exist or has expired
    iex> get_kveg_by_password_reset_link("926442b96975f7a8b5465f8f2fc28c8c")
    nil
  """
  def get_kveg_by_password_reset_link(handle) do
    if kveg_id = Kveg.ResetLink.get_kveg_id(handle) do
      get_kveg!(kveg_id)
    end
  end

  @doc """
  Create a password reset link handle for a Kveg by email.

  ## Examples

    iex> create_kveg_password_reset_link("kveg@example.com")
    "f291f70efa1e4d437f4d0d8aff997c3a"

    iex> create_kveg_password_reset_link("budeie@example.com")
    nil
  """
  def create_kveg_password_reset_link(email) do
    if kveg = Repo.get_by(Kveg, email: email) do
      Kveg.ResetLink.create_handle(kveg.id)
    end
  end

  @doc """
  Delete a password reset link handle.

  ## Examples

    iex> delete_kveg_password_reset_link("2f18a42850aade6c4b2576c84109d1dc")
    :ok
  """
  def delete_kveg_password_reset_link(handle) do
    Kveg.ResetLink.delete_handle(handle)
  end

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
  Update a Kveg password.

  ## Examples

    iex> attrs = %{"password" => "abcdef", "password_confirmation" => "abcdef"}
    %{"password" => "abcdef", "password_confirmation" => "abcdef"}

    iex> update_kveg_password(%Kveg{}, attrs)
    {:ok, %Kveg{}}

    iex> update_kveg_password(%Kveg{}, %{})
    {:error, %Ecto.Changeset{}}
  """
  def update_kveg_password(%Kveg{} = kveg, attrs) do
    kveg
    |> Kveg.password_changeset(attrs)
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

  defp calculate_purchase_totals(purchases) when is_list(purchases) do
    Enum.map(purchases, &calculate_purchase_total/1)
  end

  defp calculate_purchase_total(%Purchase{items: items} = purchase) do
    total_cost =
      Enum.reduce(items, 0, fn item, acc ->
        acc + item.count * item.unit_price_at_purchase
      end)

    Map.put(purchase, :total_cost, total_cost)
  end
end
