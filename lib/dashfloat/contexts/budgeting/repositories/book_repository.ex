defmodule DashFloat.Budgeting.Repositories.BookRepository do
  @moduledoc """
  Repository for the `Book` schema.
  """
  import Ecto.Query, warn: false

  alias DashFloat.Budgeting.Policies.BookPolicy
  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Repo

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking `Book` changes.

  ## Examples

      iex> change(book)
      %Ecto.Changeset{data: %Book{}}

  """
  @spec change(Book.t(), map()) :: Ecto.Changeset.t()
  def change(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  @doc """
  Deletes a `Book` associated with the given `user_id`.

  Returns an error if the role is unauthorized or if there
  is no association between the `Book` and `User`.

  ## Examples

      iex> delete(book, user_id)
      {:ok, %Book{}}

      iex> delete(book, user_id)
      {:error, %Ecto.Changeset{}}

      iex> delete(book, unauthorized_user_id)
      {:error, :unauthorized}

  """
  @spec delete(Book.t(), integer()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete(book, user_id) do
    with :ok <- BookPolicy.authorize(:book_delete, user_id, book) do
      Repo.delete(book)
    end
  end

  @doc """
  Gets a single `Book` associated with the given `user_id`.

  Returns `nil` if the `Book` doesn't exist or if the `User`
  is not associated with the `Book`.

  ## Examples

      iex> get(123, 123)
      %Book{}

      iex> get(456, 123)
      nil

  """
  @spec get(integer(), integer()) :: Book.t() | nil
  def get(id, user_id) do
    BookUser
    |> join(:inner, [book_user], book in assoc(book_user, :book))
    |> where([book_user, _book], book_user.user_id == ^user_id)
    |> where([_book_user, book], book.id == ^id)
    |> select([_book_user, book], book)
    |> Repo.one()
  end

  @doc """
  Returns all `Book` records associated with the given `user_id`.

  ## Examples

      iex> list(user_id)
      [%Book{}, ...]

  """
  @spec list(integer()) :: [Book.t()]
  def list(user_id) do
    BookUser
    |> join(:inner, [book_user], book in assoc(book_user, :book))
    |> where([book_user, _book], book_user.user_id == ^user_id)
    |> select([_book_user, book], book)
    |> Repo.all()
  end

  @doc """
  Updates a `Book` associated with the given `user_id`.

  Returns an error if the role is unauthorized or if there
  is no association between the `Book` and `User`.

  ## Examples

      iex> update(book, %{field: new_value}, user_id)
      {:ok, %Book{}}

      iex> update(book, %{field: bad_value}, user_id)
      {:error, %Ecto.Changeset{}}

      iex> update(book, %{field: new_value}, unauthorized_user_id)
      {:error, :unauthorized}

  """
  @spec update(Book.t(), map(), integer()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update(book, attrs, user_id) do
    with :ok <- BookPolicy.authorize(:book_update, user_id, book) do
      book
      |> Book.changeset(attrs)
      |> Repo.update()
    end
  end
end
