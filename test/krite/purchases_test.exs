defmodule Krite.PurchasesTest do
  use Krite.DataCase

  alias Krite.Purchases

  describe "purchases" do
    alias Krite.Purchases.Purchase

    import Krite.PurchasesFixtures

    @invalid_attrs %{}

    test "list_purchases/0 returns all purchases" do
      purchase = purchase_fixture()
      assert Purchases.list_purchases() == [purchase]
    end

    test "get_purchase!/1 returns the purchase with given id" do
      purchase = purchase_fixture()
      assert Purchases.get_purchase!(purchase.id) == purchase
    end

    test "create_purchase/1 with valid data creates a purchase" do
      valid_attrs = %{}

      assert {:ok, %Purchase{} = purchase} = Purchases.create_purchase(valid_attrs)
    end

    test "create_purchase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Purchases.create_purchase(@invalid_attrs)
    end

    test "update_purchase/2 with valid data updates the purchase" do
      purchase = purchase_fixture()
      update_attrs = %{}

      assert {:ok, %Purchase{} = purchase} = Purchases.update_purchase(purchase, update_attrs)
    end

    test "update_purchase/2 with invalid data returns error changeset" do
      purchase = purchase_fixture()
      assert {:error, %Ecto.Changeset{}} = Purchases.update_purchase(purchase, @invalid_attrs)
      assert purchase == Purchases.get_purchase!(purchase.id)
    end

    test "delete_purchase/1 deletes the purchase" do
      purchase = purchase_fixture()
      assert {:ok, %Purchase{}} = Purchases.delete_purchase(purchase)
      assert_raise Ecto.NoResultsError, fn -> Purchases.get_purchase!(purchase.id) end
    end

    test "change_purchase/1 returns a purchase changeset" do
      purchase = purchase_fixture()
      assert %Ecto.Changeset{} = Purchases.change_purchase(purchase)
    end
  end

  describe "purchase_items" do
    alias Krite.Purchases.PurchaseItem

    import Krite.PurchasesFixtures

    @invalid_attrs %{unit_price_at_purchase: nil, amount: nil}

    test "list_purchase_items/0 returns all purchase_items" do
      purchase_item = purchase_item_fixture()
      assert Purchases.list_purchase_items() == [purchase_item]
    end

    test "get_purchase_item!/1 returns the purchase_item with given id" do
      purchase_item = purchase_item_fixture()
      assert Purchases.get_purchase_item!(purchase_item.id) == purchase_item
    end

    test "create_purchase_item/1 with valid data creates a purchase_item" do
      valid_attrs = %{unit_price_at_purchase: 42, amount: 42}

      assert {:ok, %PurchaseItem{} = purchase_item} = Purchases.create_purchase_item(valid_attrs)
      assert purchase_item.unit_price_at_purchase == 42
      assert purchase_item.amount == 42
    end

    test "create_purchase_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Purchases.create_purchase_item(@invalid_attrs)
    end

    test "update_purchase_item/2 with valid data updates the purchase_item" do
      purchase_item = purchase_item_fixture()
      update_attrs = %{unit_price_at_purchase: 43, amount: 43}

      assert {:ok, %PurchaseItem{} = purchase_item} =
               Purchases.update_purchase_item(purchase_item, update_attrs)

      assert purchase_item.unit_price_at_purchase == 43
      assert purchase_item.amount == 43
    end

    test "update_purchase_item/2 with invalid data returns error changeset" do
      purchase_item = purchase_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Purchases.update_purchase_item(purchase_item, @invalid_attrs)

      assert purchase_item == Purchases.get_purchase_item!(purchase_item.id)
    end

    test "delete_purchase_item/1 deletes the purchase_item" do
      purchase_item = purchase_item_fixture()
      assert {:ok, %PurchaseItem{}} = Purchases.delete_purchase_item(purchase_item)
      assert_raise Ecto.NoResultsError, fn -> Purchases.get_purchase_item!(purchase_item.id) end
    end

    test "change_purchase_item/1 returns a purchase_item changeset" do
      purchase_item = purchase_item_fixture()
      assert %Ecto.Changeset{} = Purchases.change_purchase_item(purchase_item)
    end
  end
end
