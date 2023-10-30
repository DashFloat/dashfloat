defmodule DashFloat.Identity.Services.DeliverUserResetPasswordInstructions do
  @moduledoc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> call(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """

  alias DashFloat.Identity.Emails.ResetPasswordInstructionsEmail
  alias DashFloat.Identity.Repositories.UserTokenRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Mailer

  @spec call(User.t(), (binary() -> String.t())) :: {:ok, Swoosh.Email.t()} | {:error, atom()}
  def call(user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    case UserTokenRepository.create_email_token(user, "reset_password") do
      {:ok, encoded_token} ->
        url = reset_password_url_fun.(encoded_token)
        email = ResetPasswordInstructionsEmail.call(user, url)

        with {:ok, _metadata} <- Mailer.deliver(email) do
          {:ok, email}
        end

      _any ->
        {:error, :email_sending_failed}
    end
  end
end
