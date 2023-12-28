defmodule KriteWeb.CandySettingsController do
  use KriteWeb, :controller

  alias Krite.Candyshop
  alias KriteWeb.CandyAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, :edit)
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "candy" => candy_params} = params
    candy = conn.assigns.current_candy

    case Candyshop.apply_candy_email(candy, password, candy_params) do
      {:ok, applied_candy} ->
        Candyshop.deliver_candy_update_email_instructions(
          applied_candy,
          candy.email,
          &url(~p"/candies/settings/confirm_email/#{&1}")
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: ~p"/candies/settings")

      {:error, changeset} ->
        render(conn, :edit, email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "candy" => candy_params} = params
    candy = conn.assigns.current_candy

    case Candyshop.update_candy_password(candy, password, candy_params) do
      {:ok, candy} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:candy_return_to, ~p"/candies/settings")
        |> CandyAuth.log_in_candy(candy)

      {:error, changeset} ->
        render(conn, :edit, password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Candyshop.update_candy_email(conn.assigns.current_candy, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: ~p"/candies/settings")

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: ~p"/candies/settings")
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    candy = conn.assigns.current_candy

    conn
    |> assign(:email_changeset, Candyshop.change_candy_email(candy))
    |> assign(:password_changeset, Candyshop.change_candy_password(candy))
  end
end
