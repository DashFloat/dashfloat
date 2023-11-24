defmodule DashFloat.Factories.BudgetingFactory do
  @moduledoc """
  Test factories for the Budgeting context.
  """

  use ExMachina.Ecto, repo: DashFloat.Repo

  alias DashFloat.Budgeting.Schemas.Book
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Budgeting.Schemas.Category
  alias DashFloat.Budgeting.Schemas.Envelope
  alias DashFloat.Budgeting.Schemas.User

  def book_factory do
    %Book{
      name: Faker.Food.dish()
    }
  end

  def book_user_factory do
    %BookUser{
      role: :viewer
    }
  end

  def category_factory do
    %Category{
      name: Faker.Food.dish()
    }
  end

  def envelope_factory do
    %Envelope{
      name: Faker.Food.dish()
    }
  end

  def user_factory do
    %User{
      email: Faker.Internet.email(),
      hashed_password: Bcrypt.hash_pwd_salt("password")
    }
  end
end
