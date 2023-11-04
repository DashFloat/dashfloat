defmodule DashFloat.Budgeting.Policies.BookPolicy do
  @moduledoc """
  Authorization policies for the `Book` schema.
  """

  use LetMe.Policy, check_module: DashFloat.Budgeting.Policies.Checks.BookPolicyCheck

  object :book do
    # Book creation is allowed by default.
    # Change the block below if that usecase changes.
    # action :create do
    #   allow true
    # end

    action :delete do
      allow role: :admin
    end

    action :read do
      allow role: :admin
      allow role: :editor
      allow role: :viewer
    end

    action :update do
      allow role: :admin
    end
  end
end
