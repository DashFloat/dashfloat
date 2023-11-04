defmodule DashFloat.Budgeting.Repositories.BookUserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Repositories.BookUserRepository
  alias DashFloat.Budgeting.Schemas.BookUser

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
