defmodule DashFloat.Identity.Schemas.UserTest do
  use DashFloat.DataCase, async: true

  alias DashFloat.Identity.Schemas.User

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
