defmodule KriteWeb.KvegPasswordResetController do
  use KriteWeb, :controller
  alias Krite.Accounts

  def forgot_form(conn, _params) do
    render(conn, :forgot, email: nil, success: nil)
  end

  def forgot_submit(conn, %{"kveg" => %{"email" => email}}) do
    reset_link = Accounts.create_kveg_password_reset_link(email)

    if reset_link do
      # TODO: Send email
      IO.puts("Password reset link for #{email}: '#{reset_link}'")
    end

    render(conn, :forgot, email: nil, success: "Sweet, now check your email")
  end

  def reset_form(conn, %{"handle" => reset_link}) do
    if Accounts.get_kveg_by_password_reset_link(reset_link) do
      render(conn, :reset,
        success: nil,
        error: nil,
        handle: reset_link,
        enable_form: true
      )
    else
      render_reset_expired(conn)
    end
  end

  def reset_submit(conn, %{"handle" => reset_link, "kveg" => pass_params}) do
    kveg_id = Accounts.get_kveg_by_password_reset_link(reset_link)

    if kveg_id do
      case kveg_id
           |> Accounts.get_kveg!()
           |> Accounts.update_kveg_password(pass_params) do
        {:ok, _kveg} ->
          render(conn,
            success: "Perfect, now you should log in to try it out!",
            error: nil,
            handle: reset_link,
            enable_form: false
          )

        {:error, changeset} ->
          render(conn, :reset,
            success: nil,
            error: inspect(changeset.errors),
            handle: reset_link,
            enable_form: true
          )
      end
    else
      render_reset_expired(conn)
    end
  end

  defp render_reset_expired(conn) do
    render(conn, :reset,
      success: nil,
      error: "Oh my, that link seems to have expired",
      enable_form: false
    )
  end
end
