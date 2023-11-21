defmodule DashFloat.Identity.Helpers.EmailHelper do
  @moduledoc """
  Helper functions for building emails.
  """

  @app_name "DashFloat"
  @default_domain "example.com"

  @doc """
  Returns a tuple of the no-reply email address.

  ## Examples

      iex> EmailHelper.no_reply()
      {"DashFloat", "no-reply@dashfloat.com"}
  """
  @spec no_reply() :: {String.t(), String.t()}
  def no_reply do
    {sender_name(), "no-reply@#{mail_host()}"}
  end

  defp sender_name do
    if String.contains?(mail_host(), "staging") do
      @app_name <> " Staging"
    else
      @app_name
    end
  end

  defp mail_host do
    System.get_env("MAIL_HOST") || @default_domain
  end
end
