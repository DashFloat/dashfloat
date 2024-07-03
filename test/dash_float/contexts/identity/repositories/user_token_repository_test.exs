defmodule DashFloat.Identity.Repositories.UserTokenRepositoryTest do
  use DashFloat.DataCase, async: true
  
  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.IdentityConstants
  alias DashFloat.Identity.Repositories.UserTokenRepository
  alias DashFloat.Identity.Schemas.UserToken

  describe "create/2" do
    setup do
      %{user: insert(:user)}
    end

    test "with valid input returns an encoded token", %{user: user} do
      assert {:ok, token} = UserTokenRepository.create(user, "session")

      assert {:ok, _decoded_token} = Base.url_decode64(token, padding: false)
    end

    test "with valid user and session context creates a new Session UserToken", %{user: user} do
      assert {:ok, token} = UserTokenRepository.create(user, "session")

      hashed_token = hash_token(token)

      assert %UserToken{} = user_token = Repo.get_by(UserToken, token: hashed_token)
      assert user_token.context == "session"
      refute user_token.sent_to
    end

    test "with valid user and change email context creates a new Change Email UserToken", %{user: user} do
      assert {:ok, token} = UserTokenRepository.create(user, "change:#{user.email}")

      hashed_token = hash_token(token)

      assert %UserToken{} = user_token = Repo.get_by(UserToken, token: hashed_token)
      assert user_token.context == "change:#{user.email}"
      assert user_token.sent_to == user.email
    end
  end

  defp hash_token(token) do
    with {:ok, decoded_token} <- Base.url_decode64(token, padding: false) do
      :crypto.hash(IdentityConstants.hash_algorithm(), decoded_token)
    end
  end
end
