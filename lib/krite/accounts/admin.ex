defmodule Krite.Accounts.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field :email, :string
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true, redact: true

    timestamps(type: :utc_datetime)
  end

  # This exists only to manually insert new admins,
  # and is intended to be used directly by whoever
  # is maintaining the application
  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 12, max: 160)
    |> downcase_email()
    |> hash_password()
  end

  defp downcase_email(changeset) do
    if changeset.valid? do
    email = changeset
    |> get_change(:email)
    |> String.downcase()

    changeset
    |> put_change(:email, email)
      else
        changeset
        end
    end

  defp hash_password(changeset) do
    if changeset.valid? do
    password = get_change(changeset, :password)
    hash = Argon2.hash_pwd_salt(password)

    changeset
    |> put_change(:password_hash, hash)
    |> delete_change(:password)
      else
        changeset
        end
    end

  @doc """
  Verify a password.

  When no password is given, we call
  `Argon2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Krite.Accounts.Admin{password_hash: hash}, password) when byte_size(password) > 0 do
    Argon2.verify_pass(password, hash)
    end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
      end

end
