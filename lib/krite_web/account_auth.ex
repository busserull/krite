defmodule KriteWeb.AccountAuth do
  use KriteWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Krite.Accounts

  @doc """
  Log in a budeie.

  It renews the session ID and clears the whole session
  to avoid fixation attacks.
  """
  def log_in_budeie(conn, budeie) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_session(:budeie_id, budeie.id)
    |> redirect(to: ~p"/")

    # TODO: Return to budeie start page
  end

  @doc """
  Log in a kveg.

  It renews the session ID and clears the whole session
  to avoid fixation attacks.
  """
  def log_in_kveg(conn, kveg) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_session(:kveg_id, kveg.id)
    |> redirect(to: ~p"/")

    # TODO: Return to kveg home page
  end

  @doc """
  Log a budeie or kveg out.
  It clears all session data for safety.
  """
  def log_out(conn) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticate a logged in account via the session,
  be it either a budeie or a kveg.

  A logged in budeie will take precedence over a kveg,
  so that a kveg and budeie will not be able to log in
  at the same time in the same session.
  """
  def fetch_current_account(conn, _opts) do
    conn
    |> nil_accounts()
    |> maybe_fetch_budeie_or_kveg()
  end

  defp nil_accounts(conn) do
    conn
    |> assign(:current_budeie, nil)
    |> assign(:current_kveg, nil)
  end

  defp maybe_fetch_budeie_or_kveg(conn) do
    cond do
      budeie_id = get_session(conn, :budeie_id) ->
        budeie = Accounts.get_budeie!(budeie_id)
        assign(conn, :current_budeie, budeie)

      kveg_id = get_session(conn, :kveg_id) ->
        kveg = Accounts.get_kveg!(kveg_id)
        assign(conn, :current_kveg, kveg)

      true ->
        conn
    end
  end

  @doc """
  Require that a budeie is logged in, otherwise redirect and halt the connection.
  """
  def require_authenticated_budeie(conn, _opts) do
    if conn.assigns[:current_budeie] do
      conn
    else
      # TODO: Maybe remove this flash altogether
      conn
      |> put_flash(:error, "You must log in as a budeie to access that page")
      |> redirect(to: ~p"/budeie/log-in")
      |> halt()
    end
  end

  @doc """
  Require that a kveg is logged in, otherwise redirect and halt the connection.
  """
  def require_authenticated_kveg(conn, _opts) do
    if conn.assigns[:current_kveg] do
      conn
    else
      conn
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
