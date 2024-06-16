defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias KriteWeb.AccountAuth

  def index(conn, _params) do
    sauna_pass_valid =
      case conn.assigns.kveg.sauna_pass_end do
        nil -> false
        pass_end -> NaiveDateTime.after?(pass_end, NaiveDateTime.utc_now())
      end

    remind_sauna_pass = conn.assigns.kveg.sauna_pass_reminder && !sauna_pass_valid

    render(conn, :index, sauna_pass_valid: sauna_pass_valid, remind_sauna_pass: remind_sauna_pass)
  end

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

  def history(conn, _params) do
    render(conn, :history)
  end

  def sauna_pass_unremind(conn, _params) do
    conn.assigns[:kveg]
    |> Accounts.update_kveg(%{sauna_pass_reminder: false})

    conn
    |> redirect(to: ~p"/kveg")
  end
end
