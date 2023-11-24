defmodule DashFloat.Budgeting.Repositories.CategoryRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Repositories.CategoryRepository

  describe "create/1" do
    test "with valid attrs creates a new category" do
      book = insert(:book)
      attrs = %{name: "Monthly Bills", book_id: book.id}

      {:ok, category} = CategoryRepository.create(attrs)

      assert category.id
      assert category.inserted_at
      assert category.updated_at
      assert category.name == "Monthly Bills"
      assert category.book_id == book.id
    end

    test "with envelope attrs creates a new category with envelopes" do
      book = insert(:book)

      attrs = %{
        name: "Monthly Bills",
        book_id: book.id,
        envelopes: [
          %{name: "Rent"},
          %{name: "Electric"}
        ]
      }

      {:ok, category} = CategoryRepository.create(attrs)

      assert category.id
      assert Enum.count(category.envelopes) == 2

      rent = Enum.at(category.envelopes, 0)
      assert rent.name == "Rent"
      assert rent.category_id == category.id

      electric = Enum.at(category.envelopes, 1)
      assert electric.name == "Electric"
      assert electric.category_id == category.id
    end

    test "with invalid attrs returns an error changeset" do
      attrs = %{name: nil, book_id: nil}

      {:error, changeset} = CategoryRepository.create(attrs)

      assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:book_id] == {"can't be blank", [validation: :required]}
      assert Enum.count(changeset.errors) == 2
    end
  end
end
