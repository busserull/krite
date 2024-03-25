defmodule KriteWeb.AdminSettingsControllerTest do
  use KriteWeb.ConnCase, async: true

  alias Krite.AdminAccounts
  import Krite.AdminAccountsFixtures

  setup :register_and_log_in_admin

  describe "GET /admins/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, ~p"/admins/settings")
      response = html_response(conn, 200)
      assert response =~ "Settings"
    end

    test "redirects if admin is not logged in" do
      conn = build_conn()
      conn = get(conn, ~p"/admins/settings")
      assert redirected_to(conn) == ~p"/admins/log_in"
    end
  end

  describe "PUT /admins/settings (change password form)" do
    test "updates the admin password and resets tokens", %{conn: conn, admin: admin} do
      new_password_conn =
        put(conn, ~p"/admins/settings", %{
          "action" => "update_password",
          "current_password" => valid_admin_password(),
          "admin" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == ~p"/admins/settings"

      assert get_session(new_password_conn, :admin_token) != get_session(conn, :admin_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert AdminAccounts.get_admin_by_email_and_password(admin.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, ~p"/admins/settings", %{
          "action" => "update_password",
          "current_password" => "invalid",
          "admin" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "Settings"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :admin_token) == get_session(conn, :admin_token)
    end
  end

  describe "PUT /admins/settings (change email form)" do
    @tag :capture_log
    test "updates the admin email", %{conn: conn, admin: admin} do
      conn =
        put(conn, ~p"/admins/settings", %{
          "action" => "update_email",
          "current_password" => valid_admin_password(),
          "admin" => %{"email" => unique_admin_email()}
        })

      assert redirected_to(conn) == ~p"/admins/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "A link to confirm your email"

      assert AdminAccounts.get_admin_by_email(admin.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/admins/settings", %{
          "action" => "update_email",
          "current_password" => "invalid",
          "admin" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /admins/settings/confirm_email/:token" do
    setup %{admin: admin} do
      email = unique_admin_email()

      token =
        extract_admin_token(fn url ->
          AdminAccounts.deliver_admin_update_email_instructions(
            %{admin | email: email},
            admin.email,
            url
          )
        end)

      %{token: token, email: email}
    end

    test "updates the admin email once", %{conn: conn, admin: admin, token: token, email: email} do
      conn = get(conn, ~p"/admins/settings/confirm_email/#{token}")
      assert redirected_to(conn) == ~p"/admins/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Email changed successfully"

      refute AdminAccounts.get_admin_by_email(admin.email)
      assert AdminAccounts.get_admin_by_email(email)

      conn = get(conn, ~p"/admins/settings/confirm_email/#{token}")

      assert redirected_to(conn) == ~p"/admins/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, admin: admin} do
      conn = get(conn, ~p"/admins/settings/confirm_email/oops")
      assert redirected_to(conn) == ~p"/admins/settings"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Email change link is invalid or it has expired"

      assert AdminAccounts.get_admin_by_email(admin.email)
    end

    test "redirects if admin is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, ~p"/admins/settings/confirm_email/#{token}")
      assert redirected_to(conn) == ~p"/admins/log_in"
    end
  end
end
