defmodule KriteWeb.CandyResetPasswordController do
  use KriteWeb, :controller

  alias Krite.Candyshop

  plug :get_candy_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"candy" => %{"email" => email}}) do
    if candy = Candyshop.get_candy_by_email(email) do
      Candyshop.deliver_candy_reset_password_instructions(
        candy,
        &url(~p"/candies/reset_password/#{&1}")
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: ~p"/")
  end

  def edit(conn, _params) do
    render(conn, :edit, changeset: Candyshop.change_candy_password(conn.assigns.candy))
  end

  # Do not log in the candy after reset password to avoid a
  # leaked token giving the candy access to the account.
  def update(conn, %{"candy" => candy_params}) do
    case Candyshop.reset_candy_password(conn.assigns.candy, candy_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: ~p"/candies/log_in")

      {:error, changeset} ->
        render(conn, :edit, changeset: changeset)
    end
  end

  defp get_candy_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if candy = Candyshop.get_candy_by_reset_password_token(token) do
      conn |> assign(:candy, candy) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
