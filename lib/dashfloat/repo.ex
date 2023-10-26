defmodule DashFloat.Repo do
  use Ecto.Repo,
    otp_app: :dashfloat,
    adapter: Ecto.Adapters.Postgres
end
