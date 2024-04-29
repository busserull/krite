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
  Creates a purchase.

  ## Examples

      iex> create_purchase(%{field: value})
      {:ok, %Purchase{}}

      iex> create_purchase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_purchase(kveg_id, items_id_and_count) do
    item_ids = Enum.map(items_id_and_count, fn {id, _count} -> id end)

    prices_at_purchase =
      from(i in Item,
        where: i.id in ^item_ids
      )
      |> Repo.all()
      |> Map.new(fn item -> {item.id, item.price} end)

    items =
      items_id_and_count
      |> Enum.map(fn {id, count} ->
        PurchaseItem.changeset(%PurchaseItem{item_id: id}, %{
          unit_price_at_purchase: Map.fetch!(prices_at_purchase, id),
          count: count
        })
      end)

    total_cost =
      Enum.reduce(items_id_and_count, 0, fn {id, count}, acc ->
        acc + count * Map.fetch!(prices_at_purchase, id)
      end)

    %Purchase{kveg_id: kveg_id}
    |> Ecto.Changeset.change(items: items, total_cost: total_cost)
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
