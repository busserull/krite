defmodule KriteWeb.KvegController do
  alias Krite.Accounts
  use KriteWeb, :controller

  def index(conn, _params) do
    kveg = Accounts.load_kveg_balance(conn.assigns.kveg)
    render(conn, :index, kveg: kveg)
  end

  def transactions(conn, _params) do
    kveg = Accounts.load_kveg_transactions(conn.assigns.kveg)
    render(conn, :transactions, kveg: kveg)
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
