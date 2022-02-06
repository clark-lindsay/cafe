defmodule Cafe.Repo do
  use Ecto.Repo,
    otp_app: :cafe,
    adapter: Ecto.Adapters.Postgres
end
