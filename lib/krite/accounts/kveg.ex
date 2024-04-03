defmodule Krite.Accounts.Kveg do
  use Ecto.Schema
  import Ecto.Changeset
  alias Krite.Accounts.Deposit
  alias Krite.Purchases.Purchase

  schema "kveg_accounts" do
    field :email, :string
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true, redact: true

    field :active, :boolean, default: true
    field :firstname, :string
    field :lastname, :string
    field :subtitle, :string

    field :sauna_pass_end, :naive_datetime

    field :balance, :integer, default: 0, virtual: true

    has_many :deposits, Deposit
    has_many :purchases, Purchase

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(kveg, attrs) do
    kveg
    |> cast(attrs, [:email, :password, :active, :firstname, :lastname, :subtitle, :sauna_pass_end])
    |> validate_required([
    :email,
    :password,
      :active,
      :firstname,
      :lastname,
    ])
    |> downcase_email()
    |> hash_password()
  end

  defp downcase_email(changeset) do
    if changeset.valid? do
      email =
        changeset
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
  def valid_password?(%Krite.Accounts.Kveg{password_hash: hash}, password)
      when byte_size(password) > 0 do
    Argon2.verify_pass(password, hash)
    end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
    end
end
