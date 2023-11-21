defmodule Dashfloat.Identity.Helpers.EmailHelperTest do
  use DashFloat.DataCase, async: true

  alias DashFloat.Identity.Helpers.EmailHelper

  describe "no_reply/0" do
    test "with MAIL_HOST returns a no-reply email address in the correct domain" do
      System.put_env("MAIL_HOST", "dashfloat.com")

      assert EmailHelper.no_reply() == {"DashFloat", "no-reply@dashfloat.com"}
    end

    test "with MAIL_HOST that has staging returns a no-reply email address in the correct domain" do
      System.put_env("MAIL_HOST", "staging.dashfloat.com")

      assert EmailHelper.no_reply() == {"DashFloat Staging", "no-reply@staging.dashfloat.com"}
    end

    test "with no MAIL_HOST returns a no-reply email address in the default domain" do
      System.delete_env("MAIL_HOST")

      assert EmailHelper.no_reply() == {"DashFloat", "no-reply@example.com"}
    end
  end
end
