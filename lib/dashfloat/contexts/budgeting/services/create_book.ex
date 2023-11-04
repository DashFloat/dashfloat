defmodule DashFloat.Budgeting.Services.CreateBook do
  @moduledoc """
  Creates a `Book` for the given `user_id` and assigns them as an admin.

  ## Examples

      iex> CreateBook.call(123, %{field: value})
      {:ok, %Book{}}

      iex> CreateBook.call(123, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> CreateBook.call(456, %{field: value})
      {:error, :user_not_found}

  """

  alias DashFloat.Budgeting.Repositories.UserRepository
  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Repo
  alias Ecto.Multi

  @spec call(integer(), map()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()} | {:error, :user_not_found}
  def call(user_id, attrs) do
    Multi.new()
    |> Multi.run(:user, fn _repo, _changes_so_far ->
      case UserRepository.get(user_id) do
        nil -> {:error, :user_not_found}
        user -> {:ok, user}
      end
    end)
    |> Multi.insert(:book, Book.changeset(%Book{}, attrs))
    |> Multi.insert(:book_user, fn %{book: book, user: user} ->
      BookUser.changeset(%BookUser{}, %{book_id: book.id, user_id: user.id, role: :admin})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{book: book}} -> {:ok, book}
      {:error, :book, changeset, _changes_so_far} -> {:error, changeset}
      {:error, :user, error_message, _changes_so_far} -> {:error, error_message}
    end
  end
end
