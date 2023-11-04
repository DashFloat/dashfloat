defmodule DashFloat.Budgeting.Services.CreateBookTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Budgeting.Services.CreateBook
  alias DashFloat.Repo

  describe "call/2" do
    setup do
      %{user: insert(:user)}
    end

    test "with valid data creates a book", %{user: user} do
      attrs = %{name: "Test Book"}

      assert {:ok, %Book{} = book} = CreateBook.call(attrs, user.id)
      assert book.name == "Test Book"

      books_users = Repo.all(BookUser)
      assert Enum.count(books_users) == 1
    end

    test "with invalid data returns error changeset", %{user: user} do
      attrs = %{name: nil}

      assert {:error, %Ecto.Changeset{} = changeset} = CreateBook.call(attrs, user.id)

      errors = changeset.errors
      assert Enum.count(errors) == 1

      name_error = Enum.at(errors, 0)
      assert name_error == {:name, {"can't be blank", [validation: :required]}}

      books_users = Repo.all(BookUser)
      assert Enum.empty?(books_users)
    end

    test "with non-existing user returns error" do
      attrs = %{name: "Test Book"}

      assert CreateBook.call(attrs, -1) == {:error, :user_not_found}

      books_users = Repo.all(BookUser)
      assert Enum.empty?(books_users)
    end
  end
end
