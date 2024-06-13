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
    field :sauna_pass_reminder, :boolean, default: true

    field :balance, :integer, default: 0, virtual: true

    has_many :deposits, Deposit
    has_many :purchases, Purchase

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(kveg, attrs) do
    kveg
    |> cast(attrs, [
      :email,
      :password,
      :active,
      :firstname,
      :lastname,
      :subtitle,
      :sauna_pass_end,
      :sauna_pass_reminder
    ])
    |> validate_required([
      :email,
      :active,
      :firstname,
      :lastname
    ])
    |> enable_reminder_when_changing_sauna_pass()
    |> downcase_email()
    |> hash_password()
    |> validate_required([:password_hash])
  end

  defp enable_reminder_when_changing_sauna_pass(changeset) do
    if changeset.valid? && get_change(changeset, :sauna_pass_end) do
      changeset
      |> put_change(:sauna_pass_reminder, true)
    else
      changeset
    end
  end

  defp downcase_email(changeset) do
    if email = changeset.valid? && get_change(changeset, :email) do
      put_change(changeset, :email, String.downcase(email))
    else
      changeset
    end
  end

  defp hash_password(changeset) do
    if password = changeset.valid? && get_change(changeset, :password) do
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
