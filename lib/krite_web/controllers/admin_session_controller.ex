defmodule KriteWeb.AdminSessionController do
  use KriteWeb, :controller

  alias Krite.AdminAccounts
  alias KriteWeb.AdminAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"admin" => admin_params}) do
    %{"email" => email, "password" => password} = admin_params

    if admin = AdminAccounts.get_admin_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> AdminAuth.log_in_admin(admin, admin_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :new, error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> AdminAuth.log_out_admin()
  end
end
