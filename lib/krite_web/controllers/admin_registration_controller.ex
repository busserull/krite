defmodule KriteWeb.AdminRegistrationController do
  use KriteWeb, :controller

  alias Krite.AdminAccounts
  alias Krite.AdminAccounts.Admin
  alias KriteWeb.AdminAuth

  def new(conn, _params) do
    changeset = AdminAccounts.change_admin_registration(%Admin{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"admin" => admin_params}) do
    case AdminAccounts.register_admin(admin_params) do
      {:ok, admin} ->
        {:ok, _} =
          AdminAccounts.deliver_admin_confirmation_instructions(
            admin,
            &url(~p"/admins/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "Admin created successfully.")
        |> AdminAuth.log_in_admin(admin)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
