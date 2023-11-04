defmodule DashFloat.Budgeting do
  @moduledoc """
  The Budgeting context.
  """

  import Ecto.Query, warn: false

  alias DashFloat.Budgeting.Repositories.BookRepository
  alias DashFloat.Budgeting.Schemas.Book

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  @spec change_book(Book.t(), map()) :: Ecto.Changeset.t()
  defdelegate change_book(book, attrs \\ %{}), to: BookRepository, as: :change

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_book(map()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_book(attrs \\ %{}), to: BookRepository, as: :create

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_book(Book.t()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_book(book), to: BookRepository, as: :delete

  @doc """
  Gets a single book.

  ## Examples

      iex> get_book(123)
      %Book{}

      iex> get_book(456)
      nil

  """
  @spec get_book(integer()) :: Book.t() | nil
  defdelegate get_book(id), to: BookRepository, as: :get

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  @spec list_books() :: [Book.t()]
  defdelegate list_books, to: BookRepository, as: :list

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_book(Book.t(), map()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_book(book, attrs), to: BookRepository, as: :update
end
