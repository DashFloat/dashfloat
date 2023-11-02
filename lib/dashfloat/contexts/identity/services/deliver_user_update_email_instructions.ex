defmodule DashFloat.Identity.Services.DeliverUserUpdateEmailInstructions do
  @moduledoc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> call(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """

  alias DashFloat.Identity.Emails.UpdateEmailInstructionsEmail
  alias DashFloat.Identity.Repositories.UserTokenRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Mailer

  @spec call(User.t(), String.t(), (binary() -> String.t())) ::
          {:ok, Swoosh.Email.t()} | {:error, atom()}
  def call(user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    case UserTokenRepository.create_email_token(user, "change:#{current_email}") do
      {:ok, encoded_token} ->
        url = update_email_url_fun.(encoded_token)
        email = UpdateEmailInstructionsEmail.call(user, url)

        with {:ok, _metadata} <- Mailer.deliver(email) do
          {:ok, email}
        end

      # coveralls-ignore-start
      _any ->
        {:error, :email_sending_failed}
        # coveralls-ignore-stop
    end
  end
end
