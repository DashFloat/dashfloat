defmodule DashFloat.Budgeting.Repositories.EnvelopeRepository do
  @moduledoc """
  Repository for the `Envelope` schema.
  """

  alias DashFloat.Budgeting.Schemas.Envelope
  alias DashFloat.Repo

  @doc """
  Creates a new `Envelope` with the given attributes.

  ## Examples

      iex> create(%{name: "Groceries", category_id: 1})
      {:ok, %Envelope{}}
  """
  @spec create(map()) :: {:ok, Envelope.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Envelope{}
    |> Envelope.changeset(attrs)
    |> Repo.insert()
  end
end
