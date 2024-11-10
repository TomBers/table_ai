defmodule TableAi.Repo do
  use Ecto.Repo,
    otp_app: :table_ai,
    adapter: Ecto.Adapters.Postgres
end
