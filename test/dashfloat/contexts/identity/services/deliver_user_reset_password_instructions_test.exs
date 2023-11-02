defmodule DashFloat.Identity.Services.DeliverUserResetPasswordInstructionsTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Identity.Services.DeliverUserResetPasswordInstructions
  alias DashFloat.TestHelpers.IdentityHelper

  describe "call/2" do
    setup do
      %{user: insert(:user)}
    end

    test "sends token through notification", %{user: user} do
      token =
        IdentityHelper.extract_user_token(fn url ->
          DeliverUserResetPasswordInstructions.call(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end
end
