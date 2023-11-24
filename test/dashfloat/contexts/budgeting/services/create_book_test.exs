defmodule DashFloat.Budgeting.Services.CreateBookTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Budgeting.Schemas.Category
  alias DashFloat.Budgeting.Schemas.Envelope
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

    test "with valid data creates the default categories and envelopes", %{user: user} do
      attrs = %{name: "Test Book"}

      CreateBook.call(attrs, user.id)

      categories = Repo.all(Category)
      envelopes = Repo.all(Envelope)

      assert Enum.count(categories) == 5
      assert Enum.count(envelopes) == 17
    end

    test "with valid data creates the Bills Category and its envelopes", %{user: user} do
      attrs = %{name: "Test Book"}

      CreateBook.call(attrs, user.id)

      bills =
        Category
        |> Repo.get_by(%{name: "Bills"})
        |> Repo.preload(:envelopes)

      assert bills.name == "Bills"

      rent = Enum.at(bills.envelopes, 0)
      assert rent.name == "Rent / Mortgage"
      assert rent.category_id == bills.id

      electric = Enum.at(bills.envelopes, 1)
      assert electric.name == "Electric"
      assert electric.category_id == bills.id

      water = Enum.at(bills.envelopes, 2)
      assert water.name == "Water"
      assert water.category_id == bills.id

      internet = Enum.at(bills.envelopes, 3)
      assert internet.name == "Internet"
      assert internet.category_id == bills.id

      cellphone = Enum.at(bills.envelopes, 4)
      assert cellphone.name == "Cellphone"
      assert cellphone.category_id == bills.id
    end

    test "with valid data creates the Frequent Category and its envelopes", %{user: user} do
      attrs = %{name: "Test Book"}

      CreateBook.call(attrs, user.id)

      frequent =
        Category
        |> Repo.get_by(%{name: "Frequent"})
        |> Repo.preload(:envelopes)

      assert frequent.name == "Frequent"

      groceries = Enum.at(frequent.envelopes, 0)
      assert groceries.name == "Groceries"
      assert groceries.category_id == frequent.id

      eating_out = Enum.at(frequent.envelopes, 1)
      assert eating_out.name == "Eating Out"
      assert eating_out.category_id == frequent.id

      transportation = Enum.at(frequent.envelopes, 2)
      assert transportation.name == "Transportation"
      assert transportation.category_id == frequent.id
    end

    test "with valid data creates the Non-Monthly Category and its envelopes", %{user: user} do
      attrs = %{name: "Test Book"}

      CreateBook.call(attrs, user.id)

      non_monthly =
        Category
        |> Repo.get_by(%{name: "Non-Monthly"})
        |> Repo.preload(:envelopes)

      assert non_monthly.name == "Non-Monthly"

      home_maintenance = Enum.at(non_monthly.envelopes, 0)
      assert home_maintenance.name == "Home Maintenance"
      assert home_maintenance.category_id == non_monthly.id

      auto_maintenance = Enum.at(non_monthly.envelopes, 1)
      assert auto_maintenance.name == "Auto Maintenance"
      assert auto_maintenance.category_id == non_monthly.id

      gifts = Enum.at(non_monthly.envelopes, 2)
      assert gifts.name == "Gifts"
      assert gifts.category_id == non_monthly.id
    end

    test "with valid data creates the Goals Category and its envelopes", %{user: user} do
      attrs = %{name: "Test Book"}

      CreateBook.call(attrs, user.id)

      goals =
        Category
        |> Repo.get_by(%{name: "Goals"})
        |> Repo.preload(:envelopes)

      assert goals.name == "Goals"

      vacation = Enum.at(goals.envelopes, 0)
      assert vacation.name == "Vacation"
      assert vacation.category_id == goals.id

      education = Enum.at(goals.envelopes, 1)
      assert education.name == "Education"
      assert education.category_id == goals.id

      home_improvement = Enum.at(goals.envelopes, 2)
      assert home_improvement.name == "Home Improvement"
      assert home_improvement.category_id == goals.id
    end

    test "with valid data creates the Quality of Life Category and its envelopes", %{user: user} do
      attrs = %{name: "Test Book"}

      CreateBook.call(attrs, user.id)

      quality_of_life =
        Category
        |> Repo.get_by(%{name: "Quality of Life"})
        |> Repo.preload(:envelopes)

      assert quality_of_life.name == "Quality of Life"

      hobbies = Enum.at(quality_of_life.envelopes, 0)
      assert hobbies.name == "Hobbies"
      assert hobbies.category_id == quality_of_life.id

      entertainment = Enum.at(quality_of_life.envelopes, 1)
      assert entertainment.name == "Entertainment"
      assert entertainment.category_id == quality_of_life.id

      health_and_wellness = Enum.at(quality_of_life.envelopes, 2)
      assert health_and_wellness.name == "Health & Wellness"
      assert health_and_wellness.category_id == quality_of_life.id
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
