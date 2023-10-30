defmodule DashFloat.Factories.IdentityFactory do
  @moduledoc """
  Test factories for the Identity context.
  """

  use ExMachina.Ecto, repo: DashFloat.Repo

  alias DashFloat.Identity.Schemas.User
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
end
