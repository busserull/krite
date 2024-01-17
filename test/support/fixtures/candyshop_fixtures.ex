defmodule Krite.CandyshopFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Krite.Candyshop` context.
  """

  @doc """
  Generate a candy.
  """
  def candy_fixture(attrs \\ %{}) do
    {:ok, candy} =
      attrs
      |> Enum.into(%{
        calories: 42,
        name: "some name"
      })
      |> Krite.Candyshop.create_candy()

    candy
  end
end
