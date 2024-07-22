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

defmodule Helpers do
  alias Krite.Accounts.Deposit
  alias Krite.Products.{Item, Barcode, Stock}
  alias Krite.Purchases.{Purchase, PurchaseItem}

  def make_deposits({kveg, amounts}) do
    Enum.map(amounts, fn amount ->
      Deposit.changeset(
        %Deposit{kveg_id: kveg.id},
        %{amount: amount}
      )
    end)
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

  def make_purchases({buyer, all_counts}, products) do
    all_counts
    |> Enum.map(&make_one_purchase(buyer, &1, products))
  end

  def make_one_purchase(buyer, counts, products) do
    items =
      products
      |> Enum.zip(counts)
      |> Enum.reject(fn {_product, count} -> count == 0 end)
      |> Enum.map(fn {product, count} ->
        PurchaseItem.changeset(
          %PurchaseItem{item_id: product.id},
          %{
            count: count,
            unit_price_at_purchase: product.price
          }
        )
      end)

    %Purchase{kveg_id: buyer.id}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, items)
  end
end

alias Krite.Repo
alias Krite.Accounts.{Budeie, Kveg, Deposit}

# Insert kveg: name, sauna pass expires

inserted_kveg =
  [
    {"alice", ~N[2030-01-01 00:00:00]},
    {"bob", ~N[2022-01-01 00:00:00]},
    {"charlie", nil}
  ]
  |> Enum.map(fn {name, sauna_expires} ->
    %{
      firstname: String.capitalize(name),
      lastname: "Example",
      email: "#{name}@example.com",
      password: "kveg",
      sauna_pass_end: sauna_expires
    }
  end)
  |> Enum.map(&Kveg.changeset(%Kveg{}, &1))
  |> Enum.map(&Repo.insert!/1)

# Insert deposits: alice, bob, charlie

deposits = [
  [1000, 200, 250],
  [],
  [350]
]

inserted_kveg
|> Enum.zip(deposits)
|> Enum.flat_map(&Helpers.make_deposits/1)
|> Enum.each(&Repo.insert!/1)

# Insert product items: name, barcodes, price, stock

inserted_products =
  [
    {"Kvikk-Lunsj", ["1234567891011", "1234567891012"], 20, 100},
    {"Brunost", ["1234567891013"], 10, 50},
    {"Melk", [], 25, 500},
    {"Knekkebrød", ["1234567891014"], 26, 78},
    {"Paprika", ["1234567891080"], 20, 60},
    {"Tomat", ["1234567891081"], 20, 60},
    {"Jarlsberg", ["1234567891082"], 20, 60},
    {"Squash", ["1234567891083"], 20, 60},
    {"Papaya", ["1234567891084"], 20, 60},
    {"Mango", ["1234567891085"], 20, 60},
    {"Avocado", ["1234567891086"], 20, 60},
    {"Dadler", ["1234567891087"], 20, 60},
    {"Druer", ["1234567891088"], 20, 60},
    {"Kiwibær", ["1234567891089"], 20, 60},
    {"Granateple", ["1234567891090"], 20, 60},
    {"Agurk", ["1234567891091"], 20, 60},
    {"Salat", ["1234567891092"], 20, 60},
    {"Spinat", ["1234567891093"], 20, 60},
    {"Lasagne", ["1234567891094"], 20, 60}
  ]
  |> Enum.map(&Helpers.make_item/1)
  |> Enum.map(&Repo.insert!/1)

# Make purchases: [Kvikk-Lunsj, Brunost, Melk, Knekkebrød] count
alice_purchases = [
  [2, 0, 0, 0],
  [0, 1, 0, 1],
  [3, 0, 6, 2],
  [0, 0, 1, 0],
  [0, 1, 2, 0],
  [1, 1, 1, 1]
]

bob_purchases = [
  [4, 1, 0, 3]
]

charlie_pruchases = []

purchases = [
  alice_purchases,
  bob_purchases,
  charlie_pruchases
]

inserted_kveg
|> Enum.zip(purchases)
|> Enum.flat_map(&Helpers.make_purchases(&1, inserted_products))
|> Enum.map(&Repo.insert!/1)

# Make budeie accounts
%Budeie{}
|> Budeie.changeset(%{email: "milk", password: "milkman"})
|> Repo.insert!()
