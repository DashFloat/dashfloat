defmodule DashFloat.Budgeting.Repositories.BookRepository do
  @moduledoc """
  Repository for the `Book` schema.
  """
  import Ecto.Query, warn: false

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
  Updates a `Book`.

  ## Examples

      iex> update(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(Book.t(), map()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def update(book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end
end
