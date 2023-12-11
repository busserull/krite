defmodule Krite.ProductsTest do
  use Krite.DataCase

  alias Krite.Products

  describe "items" do
    alias Krite.Products.Item

    import Krite.ProductsFixtures

    @invalid_attrs %{active: nil, name: nil, barcode: nil, price: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Products.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Products.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{active: true, name: "some name", barcode: "some barcode", price: 42}

      assert {:ok, %Item{} = item} = Products.create_item(valid_attrs)
      assert item.active == true
      assert item.name == "some name"
      assert item.barcode == "some barcode"
      assert item.price == 42
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{active: false, name: "some updated name", barcode: "some updated barcode", price: 43}

      assert {:ok, %Item{} = item} = Products.update_item(item, update_attrs)
      assert item.active == false
      assert item.name == "some updated name"
      assert item.barcode == "some updated barcode"
      assert item.price == 43
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_item(item, @invalid_attrs)
      assert item == Products.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Products.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Products.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Products.change_item(item)
    end
  end

  describe "stocks" do
    alias Krite.Products.Stock

    import Krite.ProductsFixtures

    @invalid_attrs %{count: nil}

    test "list_stocks/0 returns all stocks" do
      stock = stock_fixture()
      assert Products.list_stocks() == [stock]
    end

    test "get_stock!/1 returns the stock with given id" do
      stock = stock_fixture()
      assert Products.get_stock!(stock.id) == stock
    end

    test "create_stock/1 with valid data creates a stock" do
      valid_attrs = %{count: 42}

      assert {:ok, %Stock{} = stock} = Products.create_stock(valid_attrs)
      assert stock.count == 42
    end

    test "create_stock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_stock(@invalid_attrs)
    end

    test "update_stock/2 with valid data updates the stock" do
      stock = stock_fixture()
      update_attrs = %{count: 43}

      assert {:ok, %Stock{} = stock} = Products.update_stock(stock, update_attrs)
      assert stock.count == 43
    end

    test "update_stock/2 with invalid data returns error changeset" do
      stock = stock_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_stock(stock, @invalid_attrs)
      assert stock == Products.get_stock!(stock.id)
    end

    test "delete_stock/1 deletes the stock" do
      stock = stock_fixture()
      assert {:ok, %Stock{}} = Products.delete_stock(stock)
      assert_raise Ecto.NoResultsError, fn -> Products.get_stock!(stock.id) end
    end

    test "change_stock/1 returns a stock changeset" do
      stock = stock_fixture()
      assert %Ecto.Changeset{} = Products.change_stock(stock)
    end
  end
end
