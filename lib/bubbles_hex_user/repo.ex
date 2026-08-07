defmodule BubblesHexUser.Repo do
  use Ecto.Repo,
    otp_app: :bubbles_hex_user,
    adapter: Ecto.Adapters.Postgres
end
