defmodule DashFloat.Budgeting.Repositories.BookUserRepository do
  @moduledoc """
  Repository for the `BookUser` schema.
  """

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Budgeting.Schemas.User
  alias DashFloat.Repo

  @doc """
  Gets a single `BookUser` with the given `Book` and `User`.

  If there is no association between the `Book` and `User`, `nil` is returned.

  ## Examples

      iex> get_by_book_and_user(book, user)
      %BookUser{}

      iex> get_by_book_and_user(book, other_user)
      nil

      iex> get_by_book_and_user(other_book, user)
      nil

  """
  @spec get_by_book_and_user(Book.t(), User.t()) :: BookUser.t() | nil
  def get_by_book_and_user(book, user) do
    get_by_book_id_and_user_id(book.id, user.id)
  end

  @doc """
  Gets a single `BookUser` with the given `book_id` and `user_id`.

  If there is no association between the `Book` and `User`, `nil` is returned.

  ## Examples

      iex> get_by_book_id_and_user_id(123, 123)
      %BookUser{}

      iex> get_by_book_id_and_user_id(123, 456)
      nil

      iex> get_by_book_id_and_user_id(456, 123)
      nil

  """
  @spec get_by_book_id_and_user_id(integer(), integer()) :: BookUser.t() | nil
  def get_by_book_id_and_user_id(book_id, user_id) do
    Repo.get_by(BookUser, book_id: book_id, user_id: user_id)
  end
end
