defmodule DashFloat.Identity.Repositories.UserTokenRepository do
  @moduledoc """
  Repository for the `UserToken` schema in the `Identity` context.
  """

  use DashFloat, :repository

  alias DashFloat.Identity.IdentityConstants
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken

  @doc """
  Creates a token and its hash to be delivered to external clients (user's
  email, api clients).

  The non-hashed token is sent to external clients while the hashed part is
  stored in the database. The original token cannot be reconstructed, which
  means anyone with read-only access to the database cannot directly use the
  token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery
  methods, for example, by phone numbers.

  ## Examples

      iex> create(user, "change:test@example.com")
      {:ok, "1234qwerasdfzxcv"}

      iex> create(user, "session")
      {:ok, "1234qwerasdfzxcv"}

      iex> create(user, "confirm")
      {:ok, "1234qwerasdfzxcv"}

      iex> create(user, "reset_password")
      {:ok, "1234qwerasdfzxcv"}

      iex> create(invalid_user, "change:test@example.com")
      {:error, :invalid_user}

  """
  @spec create(user :: User.t(), context :: String.t()) :: {:ok, binary()} | {:error, :invalid_user} | nil
  def create(%User{id: nil}, _context), do: {:error, :invalid_user}

  def create(user, context) do
    token = :crypto.strong_rand_bytes(IdentityConstants.rand_size())
    hashed_token = :crypto.hash(IdentityConstants.hash_algorithm(), token)

    user_token = build_token(user, hashed_token, context)

    with {:ok, _user_token} <- Repo.insert(user_token) do
      {:ok, Base.url_encode64(token, padding: false)}
    end
  end

  defp build_token(user, hashed_token, "session") do
    %UserToken{
      token: hashed_token,
      context: "session",
      user_id: user.id
    }
  end

  defp build_token(user, hashed_token, context) do
    %UserToken{
      token: hashed_token,
      context: context,
      sent_to: user.email,
      user_id: user.id
    }
  end
end
