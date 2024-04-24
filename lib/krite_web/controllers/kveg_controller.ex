defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias KriteWeb.AccountAuth

  def new(conn, _params) do
    render(conn, :new, email: nil, error_message: nil)
  end

  def create(conn, %{"kveg" => %{"email" => email, "password" => password}}) do
    IO.inspect({email, password})

    case Accounts.get_kveg_by_email_and_password(email, password) do
      nil ->
        render(conn, :new, email: email, error_message: "Hm, that's not quite right...")

      kveg ->
        AccountAuth.log_in_kveg(conn, kveg)
    end
  end

  def delete(conn, _params) do
    conn
    |> AccountAuth.log_out()
    |> redirect(to: ~p"/")
  end
end
