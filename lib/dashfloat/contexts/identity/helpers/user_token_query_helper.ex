defmodule DashFloat.Identity.Helpers.UserTokenQueryHelper do
  @moduledoc """
  Helper functions for queries related to UserToken
  """

  import Ecto.Query, warn: false

  alias DashFloat.Identity.Constants
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  @spec verify_session_token_query(binary()) :: {:ok, Ecto.Query.t()}
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(^session_validity_in_days(), "day"),
        select: user

    {:ok, query}
  end

  defp session_validity_in_days, do: Constants.session_validity_in_days()

  @doc """
  Returns the token struct for the given token value and context.
  """
  @spec token_and_context_query(binary(), String.t()) :: Ecto.Query.t()
  def token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  @spec verify_email_token_query(binary(), String.t()) :: {:ok, Ecto.Query.t()} | :error
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(Constants.hash_algorithm(), decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: Constants.confirm_validity_in_days()
  defp days_for_context("reset_password"), do: Constants.reset_password_validity_in_days()

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  This is used to validate requests to change the user
  email. It is different from `verify_email_token_query/2` precisely because
  `verify_email_token_query/2` validates the email has not changed, which is
  the starting point by this function.

  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity_in_days).
  The context must always start with "change:".
  """
  @spec verify_change_email_token_query(binary(), String.t()) :: {:ok, Ecto.Query.t()} | :error
  def verify_change_email_token_query(token, "change:" <> _email = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(Constants.hash_algorithm(), decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(^change_email_validity_in_days(), "day")

        {:ok, query}

      # coveralls-ignore-start
      :error ->
        :error
        # coveralls-ignore-stop
    end
  end

  defp change_email_validity_in_days, do: Constants.change_email_validity_in_days()

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  @spec user_and_contexts_query(User.t(), term()) :: Ecto.Query.t()
  def user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
