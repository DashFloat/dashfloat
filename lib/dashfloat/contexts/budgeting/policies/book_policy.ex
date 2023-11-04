defmodule DashFloat.Budgeting.Policies.BookPolicy do
  @moduledoc """
  Authorization policies for the `Book` schema.
  """

  use LetMe.Policy, check_module: DashFloat.Budgeting.Policies.Checks.BookPolicyCheck

  object :book do
    action :delete do
      allow role: :admin
    end

    action :update do
      allow role: :admin
    end
  end
end
