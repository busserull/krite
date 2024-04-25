defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias KriteWeb.AccountAuth

  def index(conn, _params) do
    IO.inspect(conn)

    name = conn.assigns.current_kveg.firstname
    balance = conn.assigns.current_kveg.balance
    has_sauna_pass = has_sauna_pass?(conn.assigns.current_kveg.sauna_pass_end)

    {:ok, end_at} =
      conn.assigns.current_kveg.sauna_pass_end
      |> Timex.Timezone.convert("UTC")
      |> Timex.Timezone.convert("Europe/Oslo")
      |> Timex.format("%H:%M:%S", :strftime)

    render(conn, :index,
      name: name,
      balance: balance,
      has_sauna_pass: has_sauna_pass,
      end_at: end_at
    )
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

  defp has_sauna_pass?(nil), do: false

  defp has_sauna_pass?(sauna_pass_end) do
    NaiveDateTime.after?(sauna_pass_end, NaiveDateTime.utc_now())
  end
end
