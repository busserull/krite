defmodule KriteWeb.CandyLiveTest do
  use KriteWeb.ConnCase

  import Phoenix.LiveViewTest
  import Krite.CandyshopFixtures

  @create_attrs %{name: "some name", calories: 42}
  @update_attrs %{name: "some updated name", calories: 43}
  @invalid_attrs %{name: nil, calories: nil}

  defp create_candy(_) do
    candy = candy_fixture()
    %{candy: candy}
  end

  describe "Index" do
    setup [:create_candy]

    test "lists all candies", %{conn: conn, candy: candy} do
      {:ok, _index_live, html} = live(conn, ~p"/candies")

      assert html =~ "Listing Candies"
      assert html =~ candy.name
    end

    test "saves new candy", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/candies")

      assert index_live |> element("a", "New Candy") |> render_click() =~
               "New Candy"

      assert_patch(index_live, ~p"/candies/new")

      assert index_live
             |> form("#candy-form", candy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#candy-form", candy: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/candies")

      html = render(index_live)
      assert html =~ "Candy created successfully"
      assert html =~ "some name"
    end

    test "updates candy in listing", %{conn: conn, candy: candy} do
      {:ok, index_live, _html} = live(conn, ~p"/candies")

      assert index_live |> element("#candies-#{candy.id} a", "Edit") |> render_click() =~
               "Edit Candy"

      assert_patch(index_live, ~p"/candies/#{candy}/edit")

      assert index_live
             |> form("#candy-form", candy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#candy-form", candy: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/candies")

      html = render(index_live)
      assert html =~ "Candy updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes candy in listing", %{conn: conn, candy: candy} do
      {:ok, index_live, _html} = live(conn, ~p"/candies")

      assert index_live |> element("#candies-#{candy.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#candies-#{candy.id}")
    end
  end

  describe "Show" do
    setup [:create_candy]

    test "displays candy", %{conn: conn, candy: candy} do
      {:ok, _show_live, html} = live(conn, ~p"/candies/#{candy}")

      assert html =~ "Show Candy"
      assert html =~ candy.name
    end

    test "updates candy within modal", %{conn: conn, candy: candy} do
      {:ok, show_live, _html} = live(conn, ~p"/candies/#{candy}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Candy"

      assert_patch(show_live, ~p"/candies/#{candy}/show/edit")

      assert show_live
             |> form("#candy-form", candy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#candy-form", candy: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/candies/#{candy}")

      html = render(show_live)
      assert html =~ "Candy updated successfully"
      assert html =~ "some updated name"
    end
  end
end
