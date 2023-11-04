defmodule DashFloat.Budgeting.Repositories.UserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.BudgetingFactory

  alias DashFloat.Budgeting.Repositories.UserRepository

  describe "get/1" do
    test "with existing user returns the user with given id" do
      user = insert(:user)

      assert UserRepository.get(user.id) == user
    end

    test "with non-existing user returns nil" do
      assert UserRepository.get(123) == nil
    end
  end
end
