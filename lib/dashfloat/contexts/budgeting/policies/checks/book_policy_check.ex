defmodule DashFloat.Budgeting.Policies.Checks.BookPolicyCheck do
  @moduledoc """
  Check module for `BookPolicy`.
  """

  alias DashFloat.Budgeting.Repositories.BookUserRepository
  alias DashFloat.Budgeting.Repositories.UserRepository
  alias DashFloat.Budgeting.Schemas.BookUser
  alias DashFloat.Budgeting.Schemas.User

  def role(user_id, book, role) do
    with %User{} = user <- UserRepository.get(user_id),
         %BookUser{role: ^role} <- BookUserRepository.get_by_book_and_user(book, user) do
      true
    else
      _any -> false
    end
  end
end
