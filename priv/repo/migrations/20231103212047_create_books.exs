defmodule DashFloat.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create_query = "CREATE TYPE books_users_role AS ENUM ('admin', 'editor', 'viewer')"
    drop_query = "DROP TYPE IF EXISTS books_users_role"
    execute(create_query, drop_query)

    create table(:books_users) do
      add :role, :books_users_role, null: false, default: "viewer"
      add :book_id, references(:books, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create unique_index(:books_users, [:book_id, :user_id],
             name: :books_users_book_id_user_id_unique_index
           )

    create index(:books_users, [:user_id])
  end
end
