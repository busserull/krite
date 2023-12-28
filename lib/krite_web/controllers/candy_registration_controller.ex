defmodule KriteWeb.CandyRegistrationController do
  use KriteWeb, :controller

  alias Krite.Candyshop
  alias Krite.Candyshop.Candy
  alias KriteWeb.CandyAuth

  def new(conn, _params) do
    changeset = Candyshop.change_candy_registration(%Candy{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"candy" => candy_params}) do
    case Candyshop.register_candy(candy_params) do
      {:ok, candy} ->
        {:ok, _} =
          Candyshop.deliver_candy_confirmation_instructions(
            candy,
            &url(~p"/candies/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "Candy created successfully.")
        |> CandyAuth.log_in_candy(candy)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
