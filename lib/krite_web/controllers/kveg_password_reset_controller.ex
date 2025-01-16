defmodule KriteWeb.KvegPasswordResetController do
  use KriteWeb, :controller
  alias Krite.Accounts

  def forgot_form(conn, _params) do
    render(conn, :forgot, email: nil, stop_message: nil)
  end

  def forgot_submit(conn, %{"kveg" => %{"email" => email}}) do
    reset_link = Accounts.create_kveg_password_reset_link(email)

    if reset_link do
      # TODO: Send email
      IO.puts("Password reset link for #{email}: '#{reset_link}'")
    end

    stop_message = {:success, "Sweet, now check your email"}

    render(conn, :forgot, email: nil, stop_message: stop_message)
  end

  def reset_form(conn, %{"handle" => reset_link}) do
    case Accounts.get_kveg_by_password_reset_link(reset_link) do
      nil ->
        render_reset_expired(conn)

      kveg ->
        render(
          conn,
          :reset,
          stop_message: nil,
          handle: reset_link,
          changeset: Accounts.change_kveg(kveg)
        )
    end
  end

  def reset_submit(conn, %{"handle" => reset_link, "kveg" => pass_params}) do
    kveg = Accounts.get_kveg_by_password_reset_link(reset_link)

    if kveg do
      case Accounts.update_kveg_password(kveg, pass_params) do
        {:ok, _kveg} ->
          render(
            conn,
            :reset,
            stop_message: {:success, "Perfect, now you should log in to try it out!"},
            handle: reset_link,
            changeset: nil
          )

        {:error, changeset} ->
          render(conn, :reset,
            stop_message: nil,
            handle: reset_link,
            changeset: changeset
          )
      end
    else
      render_reset_expired(conn)
    end
  end

  defp render_reset_expired(conn) do
    render(conn, :reset,
      stop_message: {:error, "Oh my, that link seems to have expired"},
      changeset: nil
    )
  end
end
