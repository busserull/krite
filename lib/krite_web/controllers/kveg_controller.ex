defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias KriteWeb.AccountAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, params) do
    IO.inspect(params)

    render(conn, :new, error_message: "Hm, that's not quite right...")
  end

  def delete(conn, _params) do
    conn
    |> AccountAuth.log_out()
    |> redirect(to: ~p"/")
    end
end
