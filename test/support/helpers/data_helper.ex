defmodule DashFloat.TestHelpers.DataHelper do
  @moduledoc """
  Helpers for generating test data.
  """

  require Ecto

  # Primitives

  def integer(range \\ 0..3_000), do: Enum.random(range)
  def uuid, do: Ecto.UUID.generate()
  def boolean, do: Enum.random([true, false])

  # Ecto

  def random_value_from_ecto_enum(enum) do
    {name, _db_value} = Enum.random(enum.__enum_map__())
    name
  end

  # Time

  def datetime_in_the_past(offset \\ nil, granularity \\ :second) do
    new_offset = offset || Enum.random(10..999_999_999)

    DateTime.add(DateTime.utc_now(), -new_offset, granularity)
  end

  def datetime_in_the_past_unix(offset \\ nil, granularity \\ :second) do
    DateTime.to_unix(datetime_in_the_past(offset, granularity), :microsecond)
  end

  # User

  def email, do: Faker.Internet.email()
  def password, do: Faker.Pizza.company()
end
