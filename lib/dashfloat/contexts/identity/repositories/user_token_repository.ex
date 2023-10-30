defmodule DashFloat.Identity.Repositories.UserTokenRepository do
  @moduledoc """
  Repository for the UserToken schema.
  """

  import Ecto.Query, warn: false

  alias DashFloat.Identity.Constants
  alias DashFloat.Identity.Helpers.UserTokenQueryHelper
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Repo

  @doc """
  Builds a UserToken and its hash to be delivered to the user's email as part of the
  registration process.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  @spec create_email_token(User.t(), String.t()) :: {:ok, binary()} | {:error, atom()}
  def create_email_token(user, context) do
    token = :crypto.strong_rand_bytes(Constants.rand_size())
    hashed_token = :crypto.hash(Constants.hash_algorithm(), token)

    attrs = %{
      token: hashed_token,
      context: context,
      sent_to: user.email,
      user_id: user.id
    }

    case create(attrs) do
      {:ok, _user_token} ->
        {:ok, Base.url_encode64(token, padding: false)}

      {:error, _changeset} ->
        {:error, :token_creation_failed}
    end
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  @spec create_session_token(User.t()) :: {:ok, binary()} | {:error, atom()}
  def create_session_token(user) do
    token = :crypto.strong_rand_bytes(Constants.rand_size())

    attrs = %{
      token: token,
      context: "session",
      user_id: user.id
    }

    case create(attrs) do
      {:ok, _user_token} ->
        {:ok, token}

      {:error, _changeset} ->
        {:error, :token_creation_failed}
    end
  end

  defp create(attrs) do
    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes the signed token with the given context.
  """
  @spec delete_session_token(binary()) :: :ok
  def delete_session_token(token) do
    token
    |> UserTokenQueryHelper.token_and_context_query("session")
    |> Repo.delete_all()

    :ok
  end
end
