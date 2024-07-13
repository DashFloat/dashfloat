defmodule DashFloat.Identity.Services.UpdateUserPassword do
  @moduledoc """
  Updates the user password.

  ## Examples

      iex> UpdateUserPassword.call(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> UpdateUserPassword.call(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}
  """

  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Repo
  alias Ecto.Multi

  @spec call(user :: User.t(), password :: String.t(), attrs :: map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def call(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Multi.new()
    |> Multi.update(:user, changeset)
    |> Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _changes} -> {:error, changeset}
    end
  end
end
