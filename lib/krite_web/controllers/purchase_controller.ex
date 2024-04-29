defmodule KriteWeb.PurchaseController do
  use KriteWeb, :controller

  alias Krite.Purchases
  alias Krite.Purchases.Purchase

  def index(conn, _params) do
    purchases = Purchases.list_purchases()
    render(conn, :index, purchases: purchases)
  end

  def new(conn, _params) do
    changeset = Purchases.change_purchase(%Purchase{})
    render(conn, :new, changeset: changeset)
  end

  # def create(conn, %{"purchase" => purchase_params}) do
  #   case Purchases.create_purchase(purchase_params) do
  #     {:ok, purchase} ->
  #       conn
  #       |> put_flash(:info, "Purchase created successfully.")
  #       |> redirect(to: ~p"/purchases/#{purchase}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :new, changeset: changeset)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    purchase = Purchases.get_purchase!(id)
    render(conn, :show, purchase: purchase)
  end

  def edit(conn, %{"id" => id}) do
    purchase = Purchases.get_purchase!(id)
    changeset = Purchases.change_purchase(purchase)
    render(conn, :edit, purchase: purchase, changeset: changeset)
  end

  def update(conn, %{"id" => id, "purchase" => purchase_params}) do
    purchase = Purchases.get_purchase!(id)

    case Purchases.update_purchase(purchase, purchase_params) do
      {:ok, purchase} ->
        conn
        |> put_flash(:info, "Purchase updated successfully.")
        |> redirect(to: ~p"/purchases/#{purchase}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, purchase: purchase, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    purchase = Purchases.get_purchase!(id)
    {:ok, _purchase} = Purchases.delete_purchase(purchase)

    conn
    |> put_flash(:info, "Purchase deleted successfully.")
    |> redirect(to: ~p"/purchases")
  end
end
