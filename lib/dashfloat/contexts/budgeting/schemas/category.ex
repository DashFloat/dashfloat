defmodule DashFloat.Budgeting.Schemas.Category do
  @moduledoc """
  `Category` is a group of `Envelope`.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.Envelope

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          name: String.t() | nil,
          book_id: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "categories" do
    field :name, :string

    belongs_to :book, Book
    has_many :envelopes, Envelope

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :book_id])
    |> validate_required([:name, :book_id])
    |> cast_assoc(:envelopes, with: &Envelope.from_category_changeset/2)
  end
end
