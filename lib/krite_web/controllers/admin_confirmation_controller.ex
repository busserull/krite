defmodule KriteWeb.AdminConfirmationController do
  use KriteWeb, :controller

  alias Krite.AdminAccounts

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"admin" => %{"email" => email}}) do
    if admin = AdminAccounts.get_admin_by_email(email) do
      AdminAccounts.deliver_admin_confirmation_instructions(
        admin,
        &url(~p"/admins/confirm/#{&1}")
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: ~p"/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, :edit, token: token)
  end

  # Do not log in the admin after confirmation to avoid a
  # leaked token giving the admin access to the account.
  def update(conn, %{"token" => token}) do
    case AdminAccounts.confirm_admin(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Admin confirmed successfully.")
        |> redirect(to: ~p"/")

      :error ->
        # If there is a current admin and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the admin themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_admin: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: ~p"/")

          %{} ->
            conn
            |> put_flash(:error, "Admin confirmation link is invalid or it has expired.")
            |> redirect(to: ~p"/")
        end
    end
  end
end
