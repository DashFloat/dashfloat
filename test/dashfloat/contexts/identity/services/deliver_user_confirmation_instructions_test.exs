defmodule DashFloat.Identity.Services.DeliverUserConfirmationInstructionsTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Identity.Services.DeliverUserConfirmationInstructions
  alias DashFloat.TestHelpers.IdentityHelper

  describe "call/2" do
    setup do
      %{user: insert(:user)}
    end

    test "sends token through notification", %{user: user} do
      token =
        IdentityHelper.extract_user_token(fn url ->
          DeliverUserConfirmationInstructions.call(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end
end
