defmodule DashFloat.Identity.Repositories.UserRepository do
  @moduledoc """
  Repository for the User schema in the Identity context.
  """

  alias DashFloat.Identity.Helpers.UserTokenQueryHelper
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Repo

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec apply_email(User.t(), String.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def apply_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_email(User.t(), map()) :: Ecto.Changeset.t()
  def change_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_password(User.t(), map()) :: Ecto.Changeset.t()
  def change_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_registration(User.t(), map()) :: Ecto.Changeset.t()
  def change_registration(user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  @spec confirm(binary()) :: {:ok, User.t()} | :error
  def confirm(token) do
    with {:ok, query} <- UserTokenQueryHelper.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- do_confirm(user) do
      {:ok, user}
    else
      _any -> :error
    end
  end

  defp do_confirm(user) do
    user
    |> confirm_multi()
    |> Repo.transaction()
  end

  defp confirm_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(
      :tokens,
      UserTokenQueryHelper.user_and_contexts_query(user, ["confirm"])
    )
  end

  @doc """
  Gets a single User.

  ## Examples

      iex> get(123)
      %User{}

      iex> get(456)
      nil

  """
  @spec get(integer()) :: User.t() | nil
  def get(id), do: Repo.get(User, id)

  @doc """
  Gets a User by email.

  ## Examples

      iex> get_by_email("foo@example.com")
      %User{}

      iex> get_by_email("unknown@example.com")
      nil

  """
  @spec get_by_email(String.t()) :: User.t() | nil
  def get_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a User by email and password.

  ## Examples

      iex> get_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_by_email_and_password(String.t(), String.t()) :: User.t() | nil
  def get_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = get_by_email(email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_by_reset_password_token("validtoken")
      %User{}

      iex> get_by_reset_password_token("invalidtoken")
      nil

  """
  @spec get_by_reset_password_token(binary()) :: User.t() | nil
  def get_by_reset_password_token(token) do
    with {:ok, query} <- UserTokenQueryHelper.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _any -> nil
    end
  end

  @doc """
  Gets a User by the given signed token.
  """
  @spec get_by_session_token(binary()) :: User.t() | nil
  def get_by_session_token(token) do
    {:ok, query} = UserTokenQueryHelper.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Registers a user.

  ## Examples

      iex> register(%{field: value})
      {:ok, %User{}}

      iex> register(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  @spec reset_password(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def reset_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserTokenQueryHelper.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  @spec update_email(User.t(), String.t()) :: :ok | :error
  def update_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserTokenQueryHelper.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- do_update_email(user, email, context) do
      :ok
    else
      _any -> :error
    end
  end

  defp do_update_email(user, email, context) do
    user
    |> user_email_multi(email, context)
    |> Repo.transaction()
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      UserTokenQueryHelper.user_and_contexts_query(user, [context])
    )
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_password(User.t(), String.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserTokenQueryHelper.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _changes_so_far} -> {:error, changeset}
    end
  end
end
