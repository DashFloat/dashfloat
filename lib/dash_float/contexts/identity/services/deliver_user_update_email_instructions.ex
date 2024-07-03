defmodule DashFloat.Identity.Services.DeliverUserUpdateEmailInstructions do
  @moduledoc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """

  alias DashFloat.Identity.Emails.UpdateEmailInstructionsEmail
  alias DashFloat.Identity.Repositories.UserTokenRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Mailer

  @spec call(user :: User.t(), current_email :: String.t(), update_email_url_fun :: (binary() -> binary())) :: {:ok, Swoosh.Email.t()} | nil
  def call(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    case UserTokenRepository.create(user, "change:#{current_email}") do
      {:ok, encoded_token} ->
        url = update_email_url_fun.(encoded_token)
        email = UpdateEmailInstructionsEmail.call(user, url)

        with {:ok, _metadata} <- Mailer.deliver(email) do
          {:ok, email}
        end

      any ->
        any
    end
  end
end
