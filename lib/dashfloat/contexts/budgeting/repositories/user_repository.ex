defmodule DashFloat.Budgeting.Repositories.UserRepository do
  @moduledoc """
  Repository for the `User` schema in the `Budgeting` context.
  """

  alias DashFloat.Budgeting.Schemas.User
  alias DashFloat.Repo

  @doc """
  Gets a single `User`.

  ## Examples

      iex> get(123)
      %User{}

      iex> get(456)
      nil

  """
  @spec get(integer()) :: User.t() | nil
  def get(id) do
    Repo.get(User, id)
  end
end
