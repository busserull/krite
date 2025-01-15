defmodule KriteWeb.KvegPasswordResetController do
  use KriteWeb, :controller

  def new(conn, _params) do
    render(conn, :new, email: nil, message: nil)
  end

  def create(conn, %{"kveg" => %{"email" => email}}) do
    IO.puts("Password reset for #{email}")
    render(conn, :new, email: nil, message: "Sweet, now check your email")
  end
end
