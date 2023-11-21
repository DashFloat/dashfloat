defmodule DashFloat.Identity.Emails.ConfirmationInstructionsEmail do
  @moduledoc """
  Deliver instructions to confirm account.
  """

  import Swoosh.Email

  alias DashFloat.Identity.Helpers.EmailHelper
  alias DashFloat.Identity.Schemas.User

  @spec call(
          User.t(),
          String.t()
        ) :: Swoosh.Email.t()
  def call(user, url) do
    body = message_body(user, url)

    new()
    |> to(user.email)
    |> from(EmailHelper.no_reply())
    |> subject("Confirmation Instructions")
    |> text_body(body)
  end

  defp message_body(user, url) do
    """
    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """
  end
end
