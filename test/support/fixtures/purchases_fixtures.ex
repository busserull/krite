defmodule Krite.PurchasesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Krite.Purchases` context.
  """

  @doc """
  Generate a purchase.
  """
  def purchase_fixture(attrs \\ %{}) do
    {:ok, purchase} =
      attrs
      |> Enum.into(%{

      })
      |> Krite.Purchases.create_purchase()

    purchase
  end

  @doc """
  Generate a purchase_item.
  """
  def purchase_item_fixture(attrs \\ %{}) do
    {:ok, purchase_item} =
      attrs
      |> Enum.into(%{
        amount: 42,
        unit_price_at_purchase: 42
      })
      |> Krite.Purchases.create_purchase_item()

    purchase_item
  end
end
