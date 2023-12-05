defmodule KriteWeb.KvegControllerTest do
  use KriteWeb.ConnCase

  import Krite.AccountsFixtures

  @create_attrs %{active: true, balance: 42, firstname: "some firstname", lastname: "some lastname", subtitle: "some subtitle", email: "some email", sauna_pass_end: ~N[2023-12-04 14:18:00]}
  @update_attrs %{active: false, balance: 43, firstname: "some updated firstname", lastname: "some updated lastname", subtitle: "some updated subtitle", email: "some updated email", sauna_pass_end: ~N[2023-12-05 14:18:00]}
  @invalid_attrs %{active: nil, balance: nil, firstname: nil, lastname: nil, subtitle: nil, email: nil, sauna_pass_end: nil}

  describe "index" do
    test "lists all kveg", %{conn: conn} do
      conn = get(conn, ~p"/kveg")
      assert html_response(conn, 200) =~ "Listing Kveg"
    end
  end

  describe "new kveg" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/kveg/new")
      assert html_response(conn, 200) =~ "New Kveg"
    end
  end

  describe "create kveg" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/kveg", kveg: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/kveg/#{id}"

      conn = get(conn, ~p"/kveg/#{id}")
      assert html_response(conn, 200) =~ "Kveg #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/kveg", kveg: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Kveg"
    end
  end

  describe "edit kveg" do
    setup [:create_kveg]

    test "renders form for editing chosen kveg", %{conn: conn, kveg: kveg} do
      conn = get(conn, ~p"/kveg/#{kveg}/edit")
      assert html_response(conn, 200) =~ "Edit Kveg"
    end
  end

  describe "update kveg" do
    setup [:create_kveg]

    test "redirects when data is valid", %{conn: conn, kveg: kveg} do
      conn = put(conn, ~p"/kveg/#{kveg}", kveg: @update_attrs)
      assert redirected_to(conn) == ~p"/kveg/#{kveg}"

      conn = get(conn, ~p"/kveg/#{kveg}")
      assert html_response(conn, 200) =~ "some updated firstname"
    end

    test "renders errors when data is invalid", %{conn: conn, kveg: kveg} do
      conn = put(conn, ~p"/kveg/#{kveg}", kveg: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Kveg"
    end
  end

  describe "delete kveg" do
    setup [:create_kveg]

    test "deletes chosen kveg", %{conn: conn, kveg: kveg} do
      conn = delete(conn, ~p"/kveg/#{kveg}")
      assert redirected_to(conn) == ~p"/kveg"

      assert_error_sent 404, fn ->
        get(conn, ~p"/kveg/#{kveg}")
      end
    end
  end

  defp create_kveg(_) do
    kveg = kveg_fixture()
    %{kveg: kveg}
  end
end
