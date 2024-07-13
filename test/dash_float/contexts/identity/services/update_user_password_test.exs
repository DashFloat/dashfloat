defmodule DashFloat.Identity.Services.UpdateUserPasswordTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Identity.Services.UpdateUserPassword
  alias DashFloat.Repo
  alias DashFloat.TestHelpers.IdentityTestHelper

  describe "update_user_password/3" do
    setup do
      password = "totally valid password"
      user = insert(:user, %{password: password})

      %{user: user, password: password}
    end

    test "validates password", %{user: user, password: password} do
      {:error, changeset} =
        UpdateUserPassword.call(user, password, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user, password: password} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        UpdateUserPassword.call(user, password, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        UpdateUserPassword.call(user, "invalid", %{password: "valid password"})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user, password: password} do
      new_password = "new valid password"

      {:ok, user} =
        UpdateUserPassword.call(user, password, %{
          password: new_password
        })

      assert is_nil(user.password)
      assert {:ok, _user} = IdentityTestHelper.fetch_user_by_email_and_password(user.email, new_password)
    end

    test "deletes all tokens for the given user", %{user: user, password: password} do
      insert(:token, %{context: "session", user_id: user.id})

      {:ok, _} =
        UpdateUserPassword.call(user, password, %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end
end
