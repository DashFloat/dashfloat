defmodule DashFloat.Budgeting.Repositories.CategoryRepository do
  @moduledoc """
  Repository for the `Category` schema.
  """

  alias DashFloat.Budgeting.Schemas.Category
  alias DashFloat.Repo

  @doc """
  Creates a new `Category` with the given attributes.

  ## Examples

      iex> create(%{name: "Monthly Bills", book_id: 1})
      {:ok, %Category{}}
  """
  @spec create(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end
end
