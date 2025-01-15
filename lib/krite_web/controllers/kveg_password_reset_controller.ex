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
    render(conn, :reset,
      success: nil,
      error: nil,
      handle: password_reset_link,
      enable_form: true
    )
  end

  def reset_submit(conn, %{"handle" => password_reset_link} = params) do
    %{"password" => password, "password_again" => password_again} = params

    if password == password_again do
      kveg_id = Accounts.get_kveg_by_password_reset_link(password_reset_link)

      {success, error} =
        if kveg_id do
          {"Perfect", nil}
        else
          {nil, "That link seems to have expired"}
        end

      render(conn, :reset,
        # success: "Perfect, now you should log in to try it out!",
        success: success,
        error: error,
        handle: password_reset_link,
        enable_form: false
      )
    else
      render(conn, :reset,
        success: nil,
        error: "Oh no, those passwords didn't quite match",
        handle: password_reset_link,
        enable_form: true
      )
    end
  end
end
