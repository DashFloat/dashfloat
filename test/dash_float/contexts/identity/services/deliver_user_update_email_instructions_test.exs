defmodule DashFloat.Identity.Services.DeliverUserUpdateEmailInstructionsTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Identity.Services.DeliverUserUpdateEmailInstructions
  alias DashFloat.TestHelpers.IdentityTestHelper

  describe "call/3" do
    setup do
      user = insert(:user)
      email = Faker.Internet.email()

      %{user: user, email: email}
    end

    test "sends token through notification", %{user: user, email: email} do
      token =
        IdentityTestHelper.extract_user_token(fn url ->
          DeliverUserUpdateEmailInstructions.call(user, email, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)

      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:#{email}"
    end
  end
end
