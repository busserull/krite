defmodule Krite.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo

  alias Krite.Products.Item
  alias Krite.Products.Barcode
  alias Krite.Products.Stock
  alias Krite.Purchases.PurchaseItem

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(from i in Item, preload: [:barcodes])
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Return a single item by one of its registered barcodes.

  ## Examples

     iex> get_item_by_barcode("701234567890")
     %Item{}

     iex> get_item_by_barcode("bad barcode")
     ** (Ecto.NoResultsError)
  """
  def get_item_by_barcode(code) do
    barcode = Repo.one!(from b in Barcode, where: b.code == ^code)
    get_item!(barcode.item_id)
  end

  @doc """
  Calculate the projected stock for an item by subtracting purchases made
  since its last stock count, from its last count.

  ## Examples

     iex> get_projected_stock(1)
     23
  """
  def get_projected_stock(id) do
    {stock, purchased_after_last_stock?} =
      case Repo.all(from s in Stock, where: s.item_id == ^id) do
        [] ->
          {0, fn _ -> true end}

        stocks ->
          last = Enum.reduce(stocks, &last_updated/2)
          count = Map.fetch!(last, :count)
          IO.puts("--> #{inspect(last.updated_at)}")
          filter = fn p -> DateTime.after?(p.purchase.updated_at, last.updated_at) end
          {count, filter}
      end

    sold =
      from(i in PurchaseItem, where: i.item_id == ^id, preload: [:purchase])
      |> Repo.all()
      |> Enum.filter(&purchased_after_last_stock?.(&1))
      |> Enum.map(& &1.count)
      |> Enum.sum()

    stock - sold
  end

  defp last_updated(one, two) do
    if DateTime.after?(one.updated_at, two.updated_at), do: one, else: two
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
