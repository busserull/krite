defmodule Krite.Purchases do
  @moduledoc """
  The Purchases context.
  """

  import Ecto.Query, warn: false
  alias Krite.Purchases.{Purchase, PurchaseItem}
  alias Krite.Products.Item
  alias Krite.Repo

  @doc """
  Returns the list of purchases.

  ## Examples

      iex> list_purchases()
      [%Purchase{}, ...]

  """
  def list_purchases do
    Repo.all(Purchase)
  end

  @doc """
  Gets a single purchase.

  Raises `Ecto.NoResultsError` if the Purchase does not exist.

  ## Examples

      iex> get_purchase!(123)
      %Purchase{}

      iex> get_purchase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_purchase!(id), do: Repo.get!(Purchase, id)

  @doc """
  Create a purchase, associating `cart` to a kveg.
  The `cart` is a list of tuples, the first element being
  a `Krite.Products.Item`, and the second being the
  count of that item.

  ## Examples

      iex> create_purchase(kveg_id, [{%Item{}, 2}, {%Item{}, 1}])
      {:ok, %Purchase{}}

  """
  def create_purchase(kveg_id, cart) do
    items =
      Enum.map(cart, fn {item, count} ->
        PurchaseItem.changeset(%PurchaseItem{}, %{
          unit_price_at_purchase: item.price,
          count: count
        })
      end)

    %Purchase{kveg_id: kveg_id, items: items}
    |> Repo.insert()
  end

  @doc """
  Updates a purchase.

  ## Examples

      iex> update_purchase(purchase, %{field: new_value})
      {:ok, %Purchase{}}

      iex> update_purchase(purchase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_purchase(%Purchase{} = purchase, attrs) do
    purchase
    |> Purchase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a purchase.

  ## Examples

      iex> delete_purchase(purchase)
      {:ok, %Purchase{}}

      iex> delete_purchase(purchase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_purchase(%Purchase{} = purchase) do
    Repo.delete(purchase)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking purchase changes.

  ## Examples

      iex> change_purchase(purchase)
      %Ecto.Changeset{data: %Purchase{}}

  """
  def change_purchase(%Purchase{} = purchase, attrs \\ %{}) do
    Purchase.changeset(purchase, attrs)
  end

  alias Krite.Purchases.PurchaseItem

  @doc """
  Returns the list of purchase_items.

  ## Examples

      iex> list_purchase_items()
      [%PurchaseItem{}, ...]

  """
  def list_purchase_items do
    Repo.all(PurchaseItem)
  end

  @doc """
  Gets a single purchase_item.

  Raises `Ecto.NoResultsError` if the Purchase item does not exist.

  ## Examples

      iex> get_purchase_item!(123)
      %PurchaseItem{}

      iex> get_purchase_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_purchase_item!(id), do: Repo.get!(PurchaseItem, id)

  @doc """
  Creates a purchase_item.

  ## Examples

      iex> create_purchase_item(%{field: value})
      {:ok, %PurchaseItem{}}

      iex> create_purchase_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_purchase_item(attrs \\ %{}) do
    %PurchaseItem{}
    |> PurchaseItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a purchase_item.

  ## Examples

      iex> update_purchase_item(purchase_item, %{field: new_value})
      {:ok, %PurchaseItem{}}

      iex> update_purchase_item(purchase_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_purchase_item(%PurchaseItem{} = purchase_item, attrs) do
    purchase_item
    |> PurchaseItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a purchase_item.

  ## Examples

      iex> delete_purchase_item(purchase_item)
      {:ok, %PurchaseItem{}}

      iex> delete_purchase_item(purchase_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_purchase_item(%PurchaseItem{} = purchase_item) do
    Repo.delete(purchase_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking purchase_item changes.

  ## Examples

      iex> change_purchase_item(purchase_item)
      %Ecto.Changeset{data: %PurchaseItem{}}

  """
  def change_purchase_item(%PurchaseItem{} = purchase_item, attrs \\ %{}) do
    PurchaseItem.changeset(purchase_item, attrs)
  end
end
