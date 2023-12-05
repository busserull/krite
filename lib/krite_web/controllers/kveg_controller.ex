defmodule KriteWeb.KvegController do
  use KriteWeb, :controller

  alias Krite.Accounts
  alias Krite.Accounts.Kveg

  def index(conn, _params) do
    kveg = Accounts.list_kveg()
    render(conn, :index, kveg_collection: kveg)
  end

  def new(conn, _params) do
    changeset = Accounts.change_kveg(%Kveg{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"kveg" => kveg_params}) do
    case Accounts.create_kveg(kveg_params) do
      {:ok, kveg} ->
        conn
        |> put_flash(:info, "Kveg created successfully.")
        |> redirect(to: ~p"/kveg/#{kveg}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    kveg = Accounts.get_kveg!(id)
    render(conn, :show, kveg: kveg)
  end

  def edit(conn, %{"id" => id}) do
    kveg = Accounts.get_kveg!(id)
    changeset = Accounts.change_kveg(kveg)
    render(conn, :edit, kveg: kveg, changeset: changeset)
  end

  def update(conn, %{"id" => id, "kveg" => kveg_params}) do
    kveg = Accounts.get_kveg!(id)

    case Accounts.update_kveg(kveg, kveg_params) do
      {:ok, kveg} ->
        conn
        |> put_flash(:info, "Kveg updated successfully.")
        |> redirect(to: ~p"/kveg/#{kveg}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, kveg: kveg, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    kveg = Accounts.get_kveg!(id)
    {:ok, _kveg} = Accounts.delete_kveg(kveg)

    conn
    |> put_flash(:info, "Kveg deleted successfully.")
    |> redirect(to: ~p"/kveg")
  end
end
