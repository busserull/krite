defmodule KriteWeb.LoginController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias KriteWeb.AccountAuth

  def kveg_new(conn, _params) do
    render(conn, :kveg_new, email: nil, error_message: nil)
  end

  def kveg_create(conn, %{"kveg" => %{"email" => email, "password" => password}}) do
    case Accounts.get_kveg_by_email_and_password(email, password) do
      nil ->
        render(conn, :kveg_new, email: email, error_message: "Hm, that's not quite right...")

      kveg ->
        AccountAuth.log_in_kveg(conn, kveg)
    end
  end

  def budeie_new(conn, _params) do
    conn
  end

  def budeie_create(conn, _params) do
    conn
  end

  def delete(conn, _params) do
    conn
    |> AccountAuth.log_out()
    |> redirect(to: ~p"/")
  end
end
