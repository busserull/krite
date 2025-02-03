defmodule KriteWeb.FeedbackController do
  use KriteWeb, :controller

  alias Krite.Feedback
  alias Krite.Feedback.Message

  def index(conn, _params) do
    messages = Feedback.list_messages()
    render(conn, :index, messages: messages)
  end

  def new(conn, _params) do
    changeset = Feedback.change_message(%Message{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params) do
    IO.puts(inspect(params, pretty: true))

    # case Feedback.create_message(message_params) do
    #   {:ok, message} ->
    #     conn
    #     |> put_flash(:info, "Message created successfully.")
    #     |> redirect(to: ~p"/messages/#{message}")

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, :new, changeset: changeset)
    # end

    render(conn, :new, changeset: Feedback.change_message(%Message{}))
  end

  def show(conn, %{"id" => id}) do
    message = Feedback.get_message!(id)
    render(conn, :show, message: message)
  end

  def edit(conn, %{"id" => id}) do
    message = Feedback.get_message!(id)
    changeset = Feedback.change_message(message)
    render(conn, :edit, message: message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Feedback.get_message!(id)

    case Feedback.update_message(message, message_params) do
      {:ok, message} ->
        conn
        |> put_flash(:info, "Message updated successfully.")
        |> redirect(to: ~p"/messages/#{message}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, message: message, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Feedback.get_message!(id)
    {:ok, _message} = Feedback.delete_message(message)

    conn
    |> put_flash(:info, "Message deleted successfully.")
    |> redirect(to: ~p"/messages")
  end
end
