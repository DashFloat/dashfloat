defmodule DashFloat.Identity.Services.DeliverUserConfirmationInstructions do
  @moduledoc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> call(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> call(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """

  alias DashFloat.Identity.Emails.ConfirmationInstructionsEmail
  alias DashFloat.Identity.Repositories.UserTokenRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Mailer

  @spec call(User.t(), (binary() -> String.t())) :: {:ok, Swoosh.Email.t()} | {:error, atom()}
  def call(user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      case UserTokenRepository.create_email_token(user, "confirm") do
        {:ok, encoded_token} ->
          url = confirmation_url_fun.(encoded_token)
          email = ConfirmationInstructionsEmail.call(user, url)

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
end
