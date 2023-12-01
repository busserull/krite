defmodule Krite.Repo do
  use Ecto.Repo,
    otp_app: :krite,
    adapter: Ecto.Adapters.Postgres
end
