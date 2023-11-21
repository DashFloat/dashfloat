defmodule DashFloat.Identity.Emails.UpdateEmailInstructionsEmail do
  @moduledoc """
  Deliver instructions to update a user email.
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
    |> subject("Update Email Instructions")
    |> text_body(body)
  end

  defp message_body(user, url) do
    """
    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """
  end
end
