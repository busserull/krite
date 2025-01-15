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

  def reset_form(conn, %{"handle" => password_reset_link}) do
    render(conn, :reset, success: nil, error: nil, handle: password_reset_link)
  end

  def reset_submit(conn, %{"kveg" => params, "handle" => password_reset_link}) do
    %{"password" => password, "password_again" => password_again} = params

    IO.puts("WE GOT:")
    IO.puts(password)
    IO.puts(password_again)

    if password != password_again do
      error = "Oh no, those passwords didn't quite match"
      render(conn, :reset, success: nil, error: error, handle: password_reset_link)
    end
  end
end
