defmodule DashFloat.Identity.Schemas.UserToken do
  @moduledoc """
  UserToken represents one of the following:

  - A token sent to the user's email to confirm their account
  - A token sent to the user's email to reset their password
  - A token sent to the user's email to change their email
  - A token stored in the session to keep the user logged in
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias DashFloat.Identity.Schemas.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          token: binary() | nil,
          context: String.t() | nil,
          sent_to: String.t() | nil,
          user_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:token, :context, :user_id, :sent_to])
    |> validate_required([:token, :context, :user_id])
  end
end
