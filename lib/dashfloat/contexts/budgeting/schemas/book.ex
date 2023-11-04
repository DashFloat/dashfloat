defmodule DashFloat.Budgeting.Schemas.Book do
  @moduledoc """
  `Book` represents a user's budget.

  This is where all transactions, categories, and everything
  that's related to budgeting is connected to.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Budgeting.Schemas.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          name: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "books" do
    field :name, :string

    many_to_many :users, User, join_through: BookUser

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
