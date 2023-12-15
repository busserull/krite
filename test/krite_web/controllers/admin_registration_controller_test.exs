defmodule KriteWeb.AdminRegistrationControllerTest do
  use KriteWeb.ConnCase, async: true

  import Krite.AdminAccountsFixtures

  describe "GET /admins/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/admins/register")
      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ ~p"/admins/log_in"
      assert response =~ ~p"/admins/register"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_admin(admin_fixture()) |> get(~p"/admins/register")

      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /admins/register" do
    @tag :capture_log
    test "creates account and logs the admin in", %{conn: conn} do
      email = unique_admin_email()

      conn =
        post(conn, ~p"/admins/register", %{
          "admin" => valid_admin_attributes(email: email)
        })

      assert get_session(conn, :admin_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ ~p"/admins/settings"
      assert response =~ ~p"/admins/log_out"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/admins/register", %{
          "admin" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
