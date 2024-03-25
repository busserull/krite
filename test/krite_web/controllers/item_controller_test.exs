defmodule KriteWeb.ItemControllerTest do
  use KriteWeb.ConnCase

  import Krite.ProductsFixtures

  @create_attrs %{active: true, name: "some name", barcode: "some barcode", price: 42}
  @update_attrs %{
    active: false,
    name: "some updated name",
    barcode: "some updated barcode",
    price: 43
  }
  @invalid_attrs %{active: nil, name: nil, barcode: nil, price: nil}

  describe "index" do
    test "lists all items", %{conn: conn} do
      conn = get(conn, ~p"/items")
      assert html_response(conn, 200) =~ "Listing Items"
    end
  end

  describe "new item" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/items/new")
      assert html_response(conn, 200) =~ "New Item"
    end
  end

  describe "create item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/items/#{id}"

      conn = get(conn, ~p"/items/#{id}")
      assert html_response(conn, 200) =~ "Item #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Item"
    end
  end

  describe "edit item" do
    setup [:create_item]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, ~p"/items/#{item}/edit")
      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "update item" do
    setup [:create_item]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/items/#{item}", item: @update_attrs)
      assert redirected_to(conn) == ~p"/items/#{item}"

      conn = get(conn, ~p"/items/#{item}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/items/#{item}", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "delete item" do
    setup [:create_item]

    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete(conn, ~p"/items/#{item}")
      assert redirected_to(conn) == ~p"/items"

      assert_error_sent 404, fn ->
        get(conn, ~p"/items/#{item}")
      end
    end
  end

  defp create_item(_) do
    item = item_fixture()
    %{item: item}
  end
end
