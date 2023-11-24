defmodule DashFloat.Budgeting.Repositories.EnvelopeRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Repositories.EnvelopeRepository

  describe "create/1" do
    test "with valid attrs creates a new envelope" do
      book = insert(:book)
      category = insert(:category, book_id: book.id)
      attrs = %{name: "Groceries", category_id: category.id}

      {:ok, envelope} = EnvelopeRepository.create(attrs)

      assert envelope.id
      assert envelope.inserted_at
      assert envelope.updated_at
      assert envelope.name == "Groceries"
      assert envelope.category_id == category.id
    end

    test "with invalid attrs returns an error changeset" do
      attrs = %{name: nil, category_id: nil}

      {:error, changeset} = EnvelopeRepository.create(attrs)

      assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:category_id] == {"can't be blank", [validation: :required]}
      assert Enum.count(changeset.errors) == 2
    end
  end
end
