defmodule DashFloat.Budgeting.Schemas.User do
  @moduledoc """
  `User` for the `Budgeting` context.
  """

  use Ecto.Schema

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          email: String.t() | nil,
          hashed_password: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "users" do
    field :email, :string

    # Not actually needed, but is needed for creating test factories
    field :hashed_password, :string, redact: true

    many_to_many :books, Book, join_through: BookUser

    timestamps(type: :utc_datetime_usec)
  end
end
