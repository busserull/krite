defmodule KriteWeb.AdminController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias KriteWeb.AccountAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"admin" => admin_params}) do
    %{"email" => email, "password" => password} = admin_params

    case Accounts.get_admin_by_email_and_password(email, password) do
      nil ->
        # Don't disclose whether the email exists,
        # in order to avoid user enumeration attacks
        render(conn, :new, error_message: "Hm, that's not quite right")

      admin ->
        conn
        |> put_flash(:info, "Welcome!")
        |> AccountAuth.log_in_admin(admin)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully")
    |> AccountAuth.log_out()
  end

  def edit(conn, _params) do
    render(conn, :edit)
  end

  def update(conn, %{"update" => update_params}) do
    conn
  end
end
