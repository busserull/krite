defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  def index(conn, _params) do
    sauna_pass_valid =
      case conn.assigns.kveg.sauna_pass_end do
        nil -> false
        pass_end -> NaiveDateTime.after?(pass_end, NaiveDateTime.utc_now())
      end

    remind_sauna_pass = conn.assigns.kveg.sauna_pass_reminder && !sauna_pass_valid

    render(conn, :index, sauna_pass_valid: sauna_pass_valid, remind_sauna_pass: remind_sauna_pass)
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
