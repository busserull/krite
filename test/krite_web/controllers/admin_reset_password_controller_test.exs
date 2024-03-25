defmodule KriteWeb.AdminResetPasswordControllerTest do
  use KriteWeb.ConnCase, async: true

  alias Krite.AdminAccounts
  alias Krite.Repo
  import Krite.AdminAccountsFixtures

  setup do
    %{admin: admin_fixture()}
  end

  describe "GET /admins/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, ~p"/admins/reset_password")
      response = html_response(conn, 200)
      assert response =~ "Forgot your password?"
    end
  end

  describe "POST /admins/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admins/reset_password", %{
          "admin" => %{"email" => admin.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(AdminAccounts.AdminToken, admin_id: admin.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/admins/reset_password", %{
          "admin" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(AdminAccounts.AdminToken) == []
    end
  end

  describe "GET /admins/reset_password/:token" do
    setup %{admin: admin} do
      token =
        extract_admin_token(fn url ->
          AdminAccounts.deliver_admin_reset_password_instructions(admin, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, ~p"/admins/reset_password/#{token}")
      assert html_response(conn, 200) =~ "Reset password"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/admins/reset_password/oops")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /admins/reset_password/:token" do
    setup %{admin: admin} do
      token =
        extract_admin_token(fn url ->
          AdminAccounts.deliver_admin_reset_password_instructions(admin, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, admin: admin, token: token} do
      conn =
        put(conn, ~p"/admins/reset_password/#{token}", %{
          "admin" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == ~p"/admins/log_in"
      refute get_session(conn, :admin_token)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Password reset successfully"

      assert AdminAccounts.get_admin_by_email_and_password(admin.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"/admins/reset_password/#{token}", %{
          "admin" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert html_response(conn, 200) =~ "something went wrong"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, ~p"/admins/reset_password/oops")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Reset password link is invalid or it has expired"
    end
  end
end
