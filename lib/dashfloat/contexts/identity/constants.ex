# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule DashFloat.Identity.Constants do
  @moduledoc """
  Constants used in the Identity context.
  """

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  def hash_algorithm, do: @hash_algorithm
  def rand_size, do: @rand_size

  def reset_password_validity_in_days, do: @reset_password_validity_in_days
  def confirm_validity_in_days, do: @confirm_validity_in_days
  def change_email_validity_in_days, do: @change_email_validity_in_days
  def session_validity_in_days, do: @session_validity_in_days
end
