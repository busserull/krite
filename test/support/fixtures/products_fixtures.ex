defmodule Krite.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Krite.Products` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        active: true,
        barcode: "some barcode",
        name: "some name",
        price: 42
      })
      |> Krite.Products.create_item()

    item
  end
end
