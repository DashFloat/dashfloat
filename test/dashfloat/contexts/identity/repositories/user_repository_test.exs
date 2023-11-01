defmodule DashFloat.Identity.Repositories.UserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Repositories.UserRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.TestHelpers.DataHelper

  describe "get/1" do
    test "returns nil if id is invalid" do
      assert nil == UserRepository.get(-1)
    end

    test "returns the user with the given id" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = UserRepository.get(user.id)
    end
  end

  describe "get_by_email/1" do
    test "returns nil if email is invalid" do
      assert nil == UserRepository.get_by_email("invalid")
    end

    test "returns the user with the given email" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = UserRepository.get_by_email(user.email)
    end
  end

  describe "get_by_email_and_password/2" do
    test "returns nil if email is invalid" do
      assert nil == UserRepository.get_by_email_and_password("invalid", "password")
    end

    test "returns nil if password is invalid" do
      user = insert(:user)
      assert nil == UserRepository.get_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      password = DataHelper.password()
      %{id: id} = user = insert(:user, hashed_password: Bcrypt.hash_pwd_salt(password))

      assert %User{id: ^id} =
               UserRepository.get_by_email_and_password(user.email, password)
    end
  end

  describe "get_by_session_token/1" do
    setup do
      user = insert(:user)
      user_token = insert(:session_token, user_id: user.id) 

      %{
        user: user,
        token: user_token.token
      }
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = UserRepository.get_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      assert UserRepository.get_by_session_token("oops") == nil
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert UserRepository.get_by_session_token(token) == nil
    end
  end
end
