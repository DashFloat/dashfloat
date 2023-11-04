defmodule DashFloat.Budgeting.Repositories.BookRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Repositories.BookRepository
  alias DashFloat.Budgeting.Schemas.Book

  describe "change/1" do
    test "returns a book changeset" do
      book = insert(:book)
      assert %Ecto.Changeset{} = BookRepository.change(book)
    end
  end

  describe "delete/1" do
    test "deletes the book" do
      book = insert(:book)

      assert {:ok, %Book{}} = BookRepository.delete(book)
      assert BookRepository.get(book.id) == nil
    end
  end

  describe "get/1" do
    test "returns the book with given id" do
      book = insert(:book)

      assert BookRepository.get(book.id) == book
    end
  end

  describe "list/1" do
    setup do
      book = insert(:book)
      user = insert(:user)

      %{book: book, user: user}
    end

    test "with associated admin returns all books", %{book: book, user: user} do
      insert(:book_user, book: book, user: user, role: :admin)

      assert BookRepository.list(user.id) == [book]
    end

    test "with associated editor returns all books", %{book: book, user: user} do
      insert(:book_user, book: book, user: user, role: :editor)

      assert BookRepository.list(user.id) == [book]
    end

    test "with associated viewer returns all books", %{book: book, user: user} do
      insert(:book_user, book: book, user: user, role: :viewer)

      assert BookRepository.list(user.id) == [book]
    end

    test "with unassociated book_user returns empty list", %{user: user} do
      assert BookRepository.list(user.id) == []
    end
  end

  describe "update/2" do
    setup do
      book = insert(:book)
      user = insert(:user)

      %{book: book, user: user}
    end

    test "with associated admin and valid data updates the book", %{book: book, user: user} do
      insert(:book_user, book: book, user: user, role: :admin)

      attrs = %{name: "Test Book Updated"}

      assert {:ok, %Book{} = book} = BookRepository.update(book, attrs, user.id)
      assert book.name == "Test Book Updated"
    end

    test "with associated editor and valid data returns error", %{book: book, user: user} do
      insert(:book_user, book: book, user: user, role: :editor)

      attrs = %{name: "Test Book Updated"}

      assert BookRepository.update(book, attrs, user.id) == {:error, :unauthorized}
    end

    test "with associated viewer and valid data returns error", %{book: book, user: user} do
      insert(:book_user, book: book, user: user, role: :viewer)

      attrs = %{name: "Test Book Updated"}

      assert BookRepository.update(book, attrs, user.id) == {:error, :unauthorized}
    end

    test "with associated book_user and invalid data returns error changeset", %{
      book: book,
      user: user
    } do
      insert(:book_user, book: book, user: user, role: :admin)

      attrs = %{name: nil}

      assert {:error, %Ecto.Changeset{}} = BookRepository.update(book, attrs, user.id)
      assert book == BookRepository.get(book.id)
    end

    test "with unassociated user and valid data returns error", %{book: book, user: user} do
      attrs = %{name: "Test Book Updated"}

      assert BookRepository.update(book, attrs, user.id) == {:error, :unauthorized}
    end
  end
end
