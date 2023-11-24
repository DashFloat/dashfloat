defmodule DashFloat.Budgeting.Services.CreateBook do
  @moduledoc """
  Creates a `Book` for the given `user_id` and assigns them as an admin.

  ## Examples

      iex> CreateBook.call(%{name: "My Book"}, user_id)
      {:ok, %Book{}}

      iex> CreateBook.call(%{name: nil}, user_id)
      {:error, %Ecto.Changeset{}}

      iex> CreateBook.call(%{name: "My Book"}, non_existing_user_id)
      {:error, :user_not_found}

  """

  alias DashFloat.Budgeting.Repositories.BookRepository
  alias DashFloat.Budgeting.Repositories.BookUserRepository
  alias DashFloat.Budgeting.Repositories.CategoryRepository
  alias DashFloat.Budgeting.Repositories.UserRepository
  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Repo
  alias Ecto.Multi

  @spec call(map(), integer()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()} | {:error, :user_not_found}
  def call(attrs, user_id) do
    Multi.new()
    |> get_user(user_id)
    |> create_book(attrs)
    |> create_book_user()
    |> create_categories_and_envelopes()
    |> Repo.transaction()
    |> case do
      {:ok, %{book: book}} -> {:ok, book}
      {:error, :book, changeset, _changes_so_far} -> {:error, changeset}
      {:error, :user, error_message, _changes_so_far} -> {:error, error_message}
    end
  end

  defp get_user(multi, user_id) do
    Multi.run(multi, :user, fn _repo, _changes_so_far ->
      case UserRepository.get(user_id) do
        nil -> {:error, :user_not_found}
        user -> {:ok, user}
      end
    end)
  end

  defp create_book(multi, attrs) do
    Multi.run(multi, :book, fn _repo, _changes_so_far ->
      BookRepository.create(attrs)
    end)
  end

  defp create_book_user(multi) do
    Multi.run(multi, :book_user, fn _repo, %{book: book, user: user} ->
      BookUserRepository.create(%{book_id: book.id, user_id: user.id, role: :admin})
    end)
  end

  defp create_categories_and_envelopes(multi) do
    Enum.reduce(default_categories_and_envelopes(), multi, fn category, multi ->
      Multi.run(multi, {:category, category.name}, fn _repo, %{book: book} ->
        CategoryRepository.create(%{
          book_id: book.id,
          name: category.name,
          envelopes: category.envelopes
        })
      end)
    end)
  end

  defp default_categories_and_envelopes do
    [
      %{
        name: "Bills",
        envelopes: [
          %{name: "Rent / Mortgage"},
          %{name: "Electric"},
          %{name: "Water"},
          %{name: "Internet"},
          %{name: "Cellphone"}
        ]
      },
      %{
        name: "Frequent",
        envelopes: [
          %{name: "Groceries"},
          %{name: "Eating Out"},
          %{name: "Transportation"}
        ]
      },
      %{
        name: "Non-Monthly",
        envelopes: [
          %{name: "Home Maintenance"},
          %{name: "Auto Maintenance"},
          %{name: "Gifts"}
        ]
      },
      %{
        name: "Goals",
        envelopes: [
          %{name: "Vacation"},
          %{name: "Education"},
          %{name: "Home Improvement"}
        ]
      },
      %{
        name: "Quality of Life",
        envelopes: [
          %{name: "Hobbies"},
          %{name: "Entertainment"},
          %{name: "Health & Wellness"}
        ]
      }
    ]
  end
end
