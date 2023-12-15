defmodule KriteWeb.AdminSessionControllerTest do
  use KriteWeb.ConnCase, async: true

  import Krite.AdminAccountsFixtures

  setup do
    %{admin: admin_fixture()}
  end

  describe "GET /admins/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, ~p"/admins/log_in")
      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ ~p"/admins/register"
      assert response =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn, admin: admin} do
      conn = conn |> log_in_admin(admin) |> get(~p"/admins/log_in")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /admins/log_in" do
    test "logs the admin in", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admins/log_in", %{
          "admin" => %{"email" => admin.email, "password" => valid_admin_password()}
        })

      assert get_session(conn, :admin_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ admin.email
      assert response =~ ~p"/admins/settings"
      assert response =~ ~p"/admins/log_out"
    end

    test "logs the admin in with remember me", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admins/log_in", %{
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_krite_web_admin_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the admin in with return to", %{conn: conn, admin: admin} do
      conn =
        conn
        |> init_test_session(admin_return_to: "/foo/bar")
        |> post(~p"/admins/log_in", %{
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "emits error message with invalid credentials", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admins/log_in", %{
          "admin" => %{"email" => admin.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /admins/log_out" do
    test "logs the admin out", %{conn: conn, admin: admin} do
      conn = conn |> log_in_admin(admin) |> delete(~p"/admins/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the admin is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/admins/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
