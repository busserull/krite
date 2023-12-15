defmodule Krite.AdminAccounts do
  @moduledoc """
  The AdminAccounts context.
  """

  import Ecto.Query, warn: false
  alias Krite.Repo

  alias Krite.AdminAccounts.Admin

  @doc """
  Get an admin by email and password.

  ## Examples

     iex> get_admin_by_email_and_password("admin@example.com", "correct password")
     %Admin{}

     iex> get_admin_by_email_and_password("admin@example.com", "wrong password")
     nil
  """
  def get_admin_by_email_and_password(email, password) do
    admin = Repo.get_by(Admin, email: email)
    if Admin.valid_password?(admin, password), do: admin
  end

  ## Database getters

  @doc """
  Gets a admin by email.

  ## Examples

      iex> get_admin_by_email("foo@example.com")
      %Admin{}

      iex> get_admin_by_email("unknown@example.com")
      nil

  """
  def get_admin_by_email(email) when is_binary(email) do
    Repo.get_by(Admin, email: email)
  end
end
