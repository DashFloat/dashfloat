defmodule DashFloat.Repo.Migrations.CreateEnvelopes do
  use Ecto.Migration

  def change do
    create table(:envelopes) do
      add :name, :string, null: false
      add :category_id, references(:categories, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:envelopes, [:category_id])
  end
end
