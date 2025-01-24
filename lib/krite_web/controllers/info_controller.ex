defmodule KriteWeb.InfoController do
  use KriteWeb, :controller

  def dypet_account(conn, _params) do
    render(conn, :dypet_account, treasurer: "Terese Ronglan Borøy")
  end
end
