defmodule DashFloat.TestHelpers.IdentityTestHelper do
  @moduledoc """
  Test helpers for the `Identity` context
  """ 

  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Repo

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def get_user!(id), do: Repo.get!(User, id)

  def fetch_user_by_email_and_password(email, password) do
    user = Repo.get_by(User, email: email)

    if Bcrypt.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end
end
