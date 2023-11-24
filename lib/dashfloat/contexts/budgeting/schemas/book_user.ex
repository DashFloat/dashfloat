defmodule DashFloat.Budgeting.Schemas.BookUser do
  @moduledoc """
  `BookUser` represents the relationship between a `Book` and a `User`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          role: atom() | nil,
          book_id: integer() | nil,
          user_id: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "books_users" do
    field :role, Ecto.Enum, values: [:admin, :editor, :viewer], default: :viewer

    belongs_to :book, Book
    belongs_to :user, User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(book_user, attrs) do
    book_user
    |> cast(attrs, [:role, :book_id, :user_id])
    |> validate_required([:book_id, :user_id])
    |> unique_constraint(:book_id, name: :books_users_book_id_user_id_unique_index)
  end
end
