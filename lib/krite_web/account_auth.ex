defmodule KriteWeb.AccountAuth do
  use KriteWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Krite.Accounts

  # TODO: Are these needed?
  # Admin remember me cookie is valid for 24 hours.
  @admin_max_age 60 * 60 * 24
  @admin_remember_me_cookie "_krite_web_admin_remember_me"
  @admin_remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Log an admin in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks.
  """
  def log_in_admin(conn, admin) do
    admin_id = Map.fetch!(admin, :id)

    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_session(:admin_id, admin_id)
    |> redirect(to: ~p"/")
    # TODO: Return to admin start page
  end

  @doc """
  Log an admin or kveg out.
  It clears all session data for safety.
  """
  def log_out(conn) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticate a logged in account via the session,
  be it either an admin or a kveg.

  A logged in admin will take precedence over a kveg,
  so that a kveg and admin will not be able to log in
  at the same time in the same session.
  """
  def fetch_current_account(conn, _opts) do
    conn
    |> nil_accounts()
    |> maybe_fetch_admin_or_kveg()
  end

  defp nil_accounts(conn) do
    conn
    |> assign(:current_admin, nil)
    |> assign(:current_kveg, nil)
  end

  defp maybe_fetch_admin_or_kveg(conn) do
    cond do
      admin_id = get_session(conn, :admin_id) ->
        admin = Accounts.get_admin!(admin_id)
        conn
        assign(conn, :current_admin, admin)

      kveg_id = get_session(conn, :kveg_id) ->
        kveg = Accounts.get_kveg!(kveg_id)
        assign(conn, :current_kveg, kveg)

      true ->
        conn
    end
  end

end
