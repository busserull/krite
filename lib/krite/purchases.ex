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
  Creates a purchase, and associates it to the Kveg determined
  by `kveg_id`. The `cart` is a mapping from `Item` id to the
  number of purchased items of that type.

  ## Examples

      iex> create_purchase(kveg_id, %{1 => 6, 2 => 4})
      {:ok, %Purchase{}}

  """
  def create_purchase(kveg_id, cart) do
    prices_at_purchase =
      from(i in Item,
        where: i.id in ^Map.keys(cart)
      )
      |> Repo.all()
      |> Map.new(fn item -> {item.id, item.price} end)

    cart_with_unit_prices =
      Map.new(cart, fn {id, count} -> {id, {count, Map.fetch!(prices_at_purchase, id)}} end)

    items =
      cart_with_unit_prices
      |> Enum.map(fn {id, {count, unit_price}} ->
        PurchaseItem.changeset(%PurchaseItem{item_id: id}, %{
          unit_price_at_purchase: unit_price,
          count: count
        })
      end)

    total_cost =
      Enum.reduce(cart_with_unit_prices, 0, fn {_id, {count, unit_price}}, acc ->
        acc + count * unit_price
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
