defmodule DashFloat.Factories.IdentityFactory do
  @moduledoc """
  Test factories for the Identity context.
  """

  use ExMachina.Ecto, repo: DashFloat.Repo

  alias DashFloat.Identity.Constants
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.TestHelpers.DataHelper

  def user_factory do
    %User{
      email: DataHelper.email(),
      hashed_password: Bcrypt.hash_pwd_salt("password")
    }
  end

  def confirmed_user_factory do
    struct!(
      user_factory(),
      %{
        confirmed_at: NaiveDateTime.utc_now()
      }
    )
  end

  def email_token_factory(attrs) do
    token = Map.get(attrs, :token, :crypto.strong_rand_bytes(Constants.rand_size()))
    hashed_token = :crypto.hash(Constants.hash_algorithm(), token)

    attrs = Map.put(attrs, :token, hashed_token)

    %UserToken{}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def session_token_factory do
    %UserToken{
      token: :crypto.strong_rand_bytes(Constants.rand_size()),
      context: "session"
    }
  end
end
