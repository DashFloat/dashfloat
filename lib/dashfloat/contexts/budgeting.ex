defmodule DashFloat.Budgeting do
  @moduledoc """
  The Budgeting context.
  """

  import Ecto.Query, warn: false

  alias DashFloat.Budgeting.Repositories.BookRepository
  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Services.CreateBook

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  @spec change_book(Book.t(), map()) :: Ecto.Changeset.t()
  defdelegate change_book(book, attrs \\ %{}), to: BookRepository, as: :change

  @doc """
  Creates a `Book` for the given `user_id` and assigns them as an admin.

  ## Examples

      iex> create_book(123, %{field: value})
      {:ok, %Book{}}

      iex> create_book(123, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_book(456, %{field: value})
      {:error, :user_not_found}

  """
  @spec create_book(map(), integer()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()} | {:error, :user_not_found}
  defdelegate create_book(attrs, user_id), to: CreateBook, as: :call

  @doc """
  Deletes a `Book`.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_book(Book.t()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_book(book), to: BookRepository, as: :delete

  @doc """
  Gets a single `Book` associated with the given `user_id`.

  Returns `nil` if the `Book` doesn't exist or if the `User`
  is not associated with the `Book`.

  ## Examples

      iex> get_book(123, 123)
      %Book{}

      iex> get_book(456, 123)
      nil

  """
  @spec get_book(integer(), integer()) :: Book.t() | nil
  defdelegate get_book(id, user_id), to: BookRepository, as: :get

  @doc """
  Returns all `Book` records associated with the given `user_id`.

  ## Examples

      iex> list_books(user_id)
      [%Book{}, ...]

  """
  @spec list_books(integer()) :: [Book.t()]
  defdelegate list_books(user_id), to: BookRepository, as: :list

  @doc """
  Updates a `Book` associated with the given `user_id`.

  Returns an error if the role is unauthorized or if there
  is no association between the `Book` and `User`.

  ## Examples

      iex> update_book(book, %{field: new_value}, user_id)
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value}, user_id)
      {:error, %Ecto.Changeset{}}

      iex> update_book(book, %{field: new_value}, unauthorized_user_id)
      {:error, :unauthorized}

  """
  @spec update_book(Book.t(), map(), integer()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  defdelegate update_book(book, attrs, user_id), to: BookRepository, as: :update
end
