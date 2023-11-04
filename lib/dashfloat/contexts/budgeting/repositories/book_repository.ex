defmodule DashFloat.Budgeting.Repositories.BookRepository do
  @moduledoc """
  Repository for the `Book` schema.
  """
  import Ecto.Query, warn: false

  alias DashFloat.Budgeting.Policies.BookPolicy
  alias DashFloat.Budgeting.Schemas.Book
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
  Deletes a `Book`.

  ## Examples

      iex> delete(book)
      {:ok, %Book{}}

      iex> delete(book)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(Book.t()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def delete(book) do
    Repo.delete(book)
  end

  @doc """
  Gets a single `Book`.

  ## Examples

      iex> get(123)
      %Book{}

      iex> get(456)
      nil

  """
  @spec get(integer()) :: Book.t() | nil
  def get(id), do: Repo.get(Book, id)

  @doc """
  Returns the list of Books.

  ## Examples

      iex> list()
      [%Book{}, ...]

  """
  @spec list() :: [Book.t()]
  def list do
    Repo.all(Book)
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
  @spec update(Book.t(), map(), integer()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def update(book, attrs, user_id) do
    with :ok <- BookPolicy.authorize(:book_update, user_id, book) do
      book
      |> Book.changeset(attrs)
      |> Repo.update()
    end
  end
end
