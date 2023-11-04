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

  describe "list/0" do
    test "returns all books" do
      book = insert(:book)

      assert BookRepository.list() == [book]
    end
  end

  describe "update/2" do
    test "with valid data updates the book" do
      book = insert(:book)
      attrs = %{name: "Test Book Updated"}

      assert {:ok, %Book{} = book} = BookRepository.update(book, attrs)
      assert book.name == "Test Book Updated"
    end

    test "with invalid data returns error changeset" do
      book = insert(:book)
      attrs = %{name: nil}

      assert {:error, %Ecto.Changeset{}} = BookRepository.update(book, attrs)
      assert book == BookRepository.get(book.id)
    end
  end
end
