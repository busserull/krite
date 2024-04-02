defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, params) do
    IO.inspect(params)

    redirect(conn, to: ~p"/log-in")
  end
end
