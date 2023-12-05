defmodule Krite.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Krite.Accounts` context.
  """

  @doc """
  Generate a kveg.
  """
  def kveg_fixture(attrs \\ %{}) do
    {:ok, kveg} =
      attrs
      |> Enum.into(%{
        active: true,
        balance: 42,
        email: "some email",
        firstname: "some firstname",
        lastname: "some lastname",
        sauna_pass_end: ~N[2023-12-04 14:18:00],
        subtitle: "some subtitle"
      })
      |> Krite.Accounts.create_kveg()

    kveg
  end
end
