# Krite

Krite is a web based system where users ("kveg") can log on, see their balance,
and purchase various products sold at Dypet.

They can also pay for a sauna session, or buy a sauna season pass.

Dypet administrators ("budeie") can log in, see available stock, update stock, and change prices.
Automatic stock reports can also be generated and downloaded.

Kveg can also organize and join trips

# Running

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# Development log

[x] Persist purchases to the database.
[x] Make `Krite.Products.list_active_items` only return active items.
[x] Highlight search match when searching in the shop.
[x] Create new cards showing account balance and sauna pass at a glance.
[ ] Refactor the back link component.
[x] Add a route explaining how to add money to Dypet.
[ ] Make it possible to directly buy a sauna pass from the home screen if a Kveg doesn't have it already.
[ ] Refactor action elements.
[ ] Add bar code scanning to devices that support it.
[ ] Create a header where login information can be placed.
[ ] Send dummy email with password reset links.
