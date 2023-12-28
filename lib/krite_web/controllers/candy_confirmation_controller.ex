defmodule KriteWeb.CandyConfirmationController do
  use KriteWeb, :controller

  alias Krite.Candyshop

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"candy" => %{"email" => email}}) do
    if candy = Candyshop.get_candy_by_email(email) do
      Candyshop.deliver_candy_confirmation_instructions(
        candy,
        &url(~p"/candies/confirm/#{&1}")
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

  # Do not log in the candy after confirmation to avoid a
  # leaked token giving the candy access to the account.
  def update(conn, %{"token" => token}) do
    case Candyshop.confirm_candy(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Candy confirmed successfully.")
        |> redirect(to: ~p"/")

      :error ->
        # If there is a current candy and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the candy themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_candy: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: ~p"/")

          %{} ->
            conn
            |> put_flash(:error, "Candy confirmation link is invalid or it has expired.")
            |> redirect(to: ~p"/")
        end
    end
  end
end
