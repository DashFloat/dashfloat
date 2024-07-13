defmodule DashFloat.Factories.IdentityFactory do
  @moduledoc """
  Test factories for the `Identity` context.
  """

  use ExMachina.Ecto, repo: DashFloat.Repo

  alias DashFloat.Identity.IdentityConstants
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken

  def user_factory(attrs) do
    password = Map.get(attrs, :password, "validpassword")
    
    attrs = Map.delete(attrs, :password)

    user = %User{
      email: Faker.Internet.email(),
      hashed_password: Bcrypt.hash_pwd_salt(password)
    }

    user
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def token_factory do
    token = :crypto.strong_rand_bytes(IdentityConstants.rand_size())
    hashed_token = :crypto.hash(IdentityConstants.hash_algorithm(), token)

    %UserToken{
      token: hashed_token
    }
  end
end
