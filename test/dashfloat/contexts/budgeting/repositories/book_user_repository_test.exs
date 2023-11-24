defmodule DashFloat.Budgeting.Repositories.BookUserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Repositories.BookUserRepository
  alias DashFloat.Budgeting.Schemas.BookUser

  describe "create/1" do
    test "with valid attrs creates a new book_user" do
      book = insert(:book)
      user = insert(:user)
      attrs = %{book_id: book.id, user_id: user.id, role: :admin}

      {:ok, book_user} = BookUserRepository.create(attrs)

      assert book_user.id
      assert book_user.inserted_at
      assert book_user.updated_at
      assert book_user.book_id == book.id
      assert book_user.user_id == user.id
      assert book_user.role == :admin
    end

    test "with no role creates a new book_user with the default role" do
      book = insert(:book)
      user = insert(:user)
      attrs = %{book_id: book.id, user_id: user.id}

      {:ok, book_user} = BookUserRepository.create(attrs)

      assert book_user.id
      assert book_user.role == :viewer
    end

    test "with existing pair returns an error" do
      book = insert(:book)
      user = insert(:user)
      insert(:book_user, book: book, user: user)
      attrs = %{book_id: book.id, user_id: user.id}

      {:error, changeset} = BookUserRepository.create(attrs)

      assert changeset.errors[:book_id] ==
               {"has already been taken",
                [constraint: :unique, constraint_name: "books_users_book_id_user_id_unique_index"]}

      assert Enum.count(changeset.errors) == 1
    end
  end

  describe "get_by_book_and_user/2" do
    test "with existing book and user returns the book_user" do
      book = insert(:book)
      user = insert(:user)
      insert(:book_user, book: book, user: user)

      assert %BookUser{} = book_user = BookUserRepository.get_by_book_and_user(book, user)
      assert book_user.book_id == book.id
      assert book_user.user_id == user.id
    end

    test "with non-associated book and user returns nil" do
      book = insert(:book)
      user = insert(:user)

      # credo:disable-for-lines:3 Credo.Check.Readability.NestedFunctionCalls
      assert BookUserRepository.get_by_book_and_user(book, insert(:user)) == nil
      assert BookUserRepository.get_by_book_and_user(insert(:book), user) == nil
      assert BookUserRepository.get_by_book_and_user(insert(:book), insert(:user)) == nil
    end
  end

  describe "get_by_book_id_and_user_id/2" do
    test "with existing book and user returns the book_user" do
      book = insert(:book)
      user = insert(:user)
      insert(:book_user, book: book, user: user)

      assert %BookUser{} =
               book_user = BookUserRepository.get_by_book_id_and_user_id(book.id, user.id)

      assert book_user.book_id == book.id
      assert book_user.user_id == user.id
    end

    test "with non-associated book and user returns nil" do
      book = insert(:book)
      user = insert(:user)

      # credo:disable-for-lines:4 Credo.Check.Readability.NestedFunctionCalls
      assert BookUserRepository.get_by_book_id_and_user_id(book.id, insert(:user).id) == nil
      assert BookUserRepository.get_by_book_id_and_user_id(insert(:book).id, user.id) == nil

      assert BookUserRepository.get_by_book_id_and_user_id(insert(:book).id, insert(:user).id) ==
               nil
    end
  end
end
