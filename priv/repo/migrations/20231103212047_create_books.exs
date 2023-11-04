defmodule DashFloat.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string

      timestamps(type: :timestamptz)
    end
  end
end
