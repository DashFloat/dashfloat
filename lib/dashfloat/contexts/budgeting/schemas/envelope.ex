defmodule DashFloat.Budgeting.Schemas.Envelope do
  @moduledoc """
  `Envelope` is the representation of a specific thing that you want to budget for.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias DashFloat.Budgeting.Schemas.Category

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          name: String.t() | nil,
          category_id: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "envelopes" do
    field :name, :string

    belongs_to :category, Category

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(envelope, attrs) do
    envelope
    |> cast(attrs, [:name, :category_id])
    |> validate_required([:name, :category_id])
  end

  @doc false
  @spec from_category_changeset(t(), map()) :: Ecto.Changeset.t()
  def from_category_changeset(envelope, attrs) do
    envelope
    |> cast(attrs, [:name, :category_id])
    |> validate_required([:name])
  end
end
