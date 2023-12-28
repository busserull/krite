defmodule KriteWeb.CandySessionController do
  use KriteWeb, :controller

  alias Krite.Candyshop
  alias KriteWeb.CandyAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"candy" => candy_params}) do
    %{"email" => email, "password" => password} = candy_params

    if candy = Candyshop.get_candy_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> CandyAuth.log_in_candy(candy, candy_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :new, error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> CandyAuth.log_out_candy()
  end
end
