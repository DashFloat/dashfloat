defmodule DashFloat.Identity.Services.DeliverUserUpdateEmailInstructionsTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Constants
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Identity.Services.DeliverUserUpdateEmailInstructions
  alias DashFloat.TestHelpers.DataHelper
  alias DashFloat.TestHelpers.IdentityHelper

  describe "call/3" do
    setup do
      user = insert(:user)
      email = DataHelper.email()

      %{user: user, email: email}
    end

    test "sends token through notification", %{user: user, email: email} do
      token =
        IdentityHelper.extract_user_token(fn url ->
          DeliverUserUpdateEmailInstructions.call(user, email, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)

      assert user_token =
               Repo.get_by(UserToken, token: :crypto.hash(Constants.hash_algorithm(), token))

      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:#{email}"
    end
  end
end
