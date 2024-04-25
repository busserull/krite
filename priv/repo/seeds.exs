# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Krite.Repo.insert!(%Krite.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Krite.Accounts.Kveg

defmodule SeedUtil do
  alias Krite.Accounts.{Kveg, Deposit}
  alias Krite.Products.{Item, Barcode, Stock}
  alias Krite.Purchases.{Purchase, PurchaseItem}

  def make_kveg({firstname, lastname, email}) do
    Kveg.changeset(
      %Kveg{},
      %{
        firstname: firstname,
        lastname: lastname,
        email: email
      }
    )
  end

  def make_deposit({kveg, amount}) do
    Deposit.changeset(
      %Deposit{kveg_id: kveg.id},
      %{
        amount: amount
      }
    )
  end

  def make_item({name, barcodes, price, stock}) do
    barcodes = Enum.map(barcodes, &Barcode.changeset(%Barcode{}, %{code: &1}))

    ten_minutes_ago =
      DateTime.utc_now() |> DateTime.add(-10, :minute) |> DateTime.truncate(:second)

    stocks = [
      Stock.changeset(
        %Stock{
          inserted_at: ten_minutes_ago,
          updated_at: ten_minutes_ago
        },
        %{count: stock}
      )
    ]

    %Item{}
    |> Item.changeset(%{name: name, price: price})
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:barcodes, barcodes)
    |> Ecto.Changeset.put_assoc(:stocks, stocks)
  end

  def make_purchase({buyer, counts}, products) do
    items =
      counts
      |> Enum.zip(products)
      |> Enum.reject(fn {count, _product} -> count == 0 end)
      |> Enum.map(fn {count, product} ->
        PurchaseItem.changeset(%PurchaseItem{item_id: product.id}, %{
          count: count,
          unit_price_at_purchase: product.price
        })
      end)

    %Purchase{kveg_id: buyer.id}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, items)
  end
end

alias Krite.Repo
alias Krite.Accounts.Budeie

# Insert kveg

inserted_kveg =
  [{"alice", 3}, {"bob", -10}, {"charlie", 10 * 60 * 24}]
  |> Enum.map(fn {name, sauna_valid_minutes} ->
    {name, DateTime.add(DateTime.utc_now(), sauna_valid_minutes, :minute)}
  end)
  |> Enum.map(fn {name, sauna_end} ->
    %{
      firstname: String.capitalize(name),
      lastname: "Example",
      email: "#{name}@example.com",
      password: "kveg",
      sauna_pass_end: sauna_end
    }
  end)
  |> Enum.map(fn changes -> Kveg.changeset(%Kveg{}, changes) end)
  |> Enum.map(&Repo.insert!(&1))

# Insert product items

inserted_products =
  [
    {"Liquid Water", ["7012345678900", "7012345678905", "7012345678909"], 21, 50},
    {"Viscous Air", ["6402345678901"], 25, 25},
    {"Brunder Brau", ["4402345678901"], 12, 300}
  ]
  |> Enum.map(&SeedUtil.make_item/1)
  |> Enum.map(&Repo.insert!(&1, []))

# Make deposits

inserted_kveg
|> Stream.cycle()
|> Enum.zip([250, 175, 312, 456, 36, 73])
|> Enum.map(&SeedUtil.make_deposit/1)
|> Enum.each(&Repo.insert!(&1, []))

# Make purchases
purchase_counts = [
  [1, 0, 0],
  [3, 2, 0],
  [4, 1, 3],
  [0, 5, 0],
  [1, 0, 3],
  [0, 2, 6]
]

inserted_kveg
|> Stream.cycle()
|> Enum.zip(purchase_counts)
|> Enum.map(&SeedUtil.make_purchase(&1, inserted_products))
|> Enum.each(&Repo.insert!(&1, []))

# Make budeie accounts
%Budeie{}
|> Budeie.changeset(%{email: "milk", password: "milkman"})
|> Repo.insert!()
