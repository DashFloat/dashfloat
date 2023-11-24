defmodule DashFloat.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :book_id, references(:books, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:categories, [:book_id])
  end
end
