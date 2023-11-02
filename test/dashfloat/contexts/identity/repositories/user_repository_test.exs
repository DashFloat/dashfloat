defmodule DashFloat.Identity.Repositories.UserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Constants
  alias DashFloat.Identity.Repositories.UserRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.TestHelpers.DataHelper

  describe "apply_email/3" do
    setup do
      password = DataHelper.password()
      user = insert(:user, hashed_password: Bcrypt.hash_pwd_salt(password))

      %{
        user: user,
        password: password
      }
    end

    test "requires email to change", %{user: user, password: password} do
      {:error, changeset} = UserRepository.apply_email(user, password, %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user, password: password} do
      {:error, changeset} =
        UserRepository.apply_email(user, password, %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user, password: password} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        UserRepository.apply_email(user, password, %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      password = DataHelper.password()
      %{email: email} = insert(:user, hashed_password: Bcrypt.hash_pwd_salt(password))

      {:error, changeset} = UserRepository.apply_email(user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        UserRepository.apply_email(user, "invalid", %{email: DataHelper.email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user, password: password} do
      email = DataHelper.email()
      {:ok, user} = UserRepository.apply_email(user, password, %{email: email})
      assert user.email == email
      assert UserRepository.get(user.id).email != email
    end
  end

  describe "change_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = UserRepository.change_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "change_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = UserRepository.change_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        UserRepository.change_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = UserRepository.change_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = DataHelper.email()
      password = DataHelper.password()

      attrs = %{
        email: email,
        password: password
      }

      changeset =
        UserRepository.change_registration(
          %User{},
          attrs
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "confirm/1" do
    setup do
      user = insert(:user)
      token = :crypto.strong_rand_bytes(Constants.rand_size())
      insert(:email_token, token: token, user: user, sent_to: user.email, context: "confirm")

      %{user: user, token: Base.url_encode64(token, padding: false)}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = UserRepository.confirm(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert UserRepository.confirm("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert UserRepository.confirm(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

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

  describe "get_by_reset_password_token/1" do
    setup do
      user = insert(:user)
      token = :crypto.strong_rand_bytes(Constants.rand_size())

      insert(:email_token,
        token: token,
        user: user,
        sent_to: user.email,
        context: "reset_password"
      )

      %{user: user, token: Base.url_encode64(token, padding: false)}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = UserRepository.get_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute UserRepository.get_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute UserRepository.get_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "get_by_session_token/1" do
    setup do
      user = insert(:user)
      user_token = insert(:session_token, user: user)

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

  describe "register/1" do
    test "requires email and password to be set" do
      {:error, changeset} = UserRepository.register(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = UserRepository.register(%{email: "not valid", password: "novalid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 8 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = UserRepository.register(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = insert(:user)
      {:error, changeset} = UserRepository.register(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = UserRepository.register(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = DataHelper.email()

      attrs = %{
        email: email,
        password: DataHelper.password()
      }

      {:ok, user} = UserRepository.register(attrs)
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "reset_password/2" do
    setup do
      %{user: insert(:user)}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        UserRepository.reset_password(user, %{
          password: "novalid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 8 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = UserRepository.reset_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = UserRepository.reset_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert UserRepository.get_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      insert(:session_token, user: user)
      {:ok, _} = UserRepository.reset_password(user, %{password: "new valid password"})
      assert Repo.get_by(UserToken, user_id: user.id) == nil
    end
  end

  describe "update_email/2" do
    setup do
      user = insert(:user)
      email = DataHelper.email()
      token = :crypto.strong_rand_bytes(Constants.rand_size())

      insert(:email_token,
        token: token,
        user: user,
        sent_to: email,
        context: "change:#{user.email}"
      )

      %{user: user, token: Base.url_encode64(token, padding: false), email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert UserRepository.update_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id) == nil
    end

    test "does not update email with invalid token", %{user: user} do
      assert UserRepository.update_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert UserRepository.update_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert UserRepository.update_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "update_password/3" do
    setup do
      password = DataHelper.password()
      user = insert(:user, hashed_password: Bcrypt.hash_pwd_salt(password))

      %{
        user: user,
        password: password
      }
    end

    test "validates password", %{user: user, password: password} do
      {:error, changeset} =
        UserRepository.update_password(user, password, %{
          password: "novalid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 8 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user, password: password} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        UserRepository.update_password(user, password, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        UserRepository.update_password(user, "invalid", %{password: DataHelper.password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user, password: password} do
      {:ok, user} =
        UserRepository.update_password(user, password, %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert UserRepository.get_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user, password: password} do
      insert(:session_token, user: user)

      {:ok, _} =
        UserRepository.update_password(user, password, %{
          password: "new valid password"
        })

      assert Repo.get_by(UserToken, user_id: user.id) == nil
    end
  end
end
