# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Parking.Repo.insert!(%Parking.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Parking.AccessLayer.SearchSpace
alias Parking.AccessLayer.BookSpace
alias Parking.{Repo, Accounts.User, Sales.Space}

[
  %{
    name: "Fred Flintstone",
    email: "ayodeleeenitilo@gmail.com", #Any valid email of user
    username: "fred",
    password: "parool",
    role: "customer",
    credit_card_number: "5167000000000000",
    cvv: "123",
    valid_date: "09/20",
    account_balance: 5000,
    monthly_payment: false
  },
  %{
    name: "Barney Rubble",
    email: "a@gmail.com",
    username: "barney",
    password: "parool",
    role: "customer",
    credit_card_number: "5177000000000000",
    cvv: "103",
    valid_date: "09/20",
    account_balance: 5000,
    monthly_payment: false
  }
]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

# [%{location: "Narva 25", username: "taxi_driver1", status: "busy"},
#  %{location: "Raatuse 22", username: "taxi_driver2", status: "available"}]
# |> Enum.map(fn taxi_data -> Taxi.changeset(%Taxi{}, taxi_data) end)
# |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

zones = [
  %{zone_type: "A", hourly_rate: 2, real_time_rate: 0.16},
  %{zone_type: "B", hourly_rate: 1, real_time_rate: 0.08}
]

Enum.each(zones, fn data ->
  SearchSpace.create_zone(data)
end)

spaces = [
  %{longitude: 24.77177, latitude: 59.43894, status: "Booked", zone_id: 2},
  %{longitude: 26.722815, latitude: 58.380196, status: "Available", zone_id: 2},
  %{longitude: 26.719978, latitude: 59.43894, status: "Booked", zone_id: 1},
  %{longitude: 26.705402, latitude: 58.386141, status: "Available", zone_id: 1},
  %{longitude: 26.747716, latitude: 58.382181, status: "Available", zone_id: 1},
  %{longitude: 26.714242, latitude: 58.383171, status: "Available", zone_id: 1},
  %{longitude: 26.727570, latitude: 58.377063, status: "Available", zone_id: 2},
  %{longitude: 26.722051, latitude: 58.374839, status: "Available", zone_id: 2},
  %{longitude: 26.733824, latitude: 58.377152, status: "Booked", zone_id: 1},
  %{longitude: 26.729275, latitude: 58.375982, status: "Available", zone_id: 1},
  %{longitude: 26.723825, latitude: 58.378092, status: "Available", zone_id: 1},
  %{longitude: 26.717613, latitude: 58.379588, status: "Available", zone_id: 1}
]

Enum.each(spaces, fn data ->
  SearchSpace.create_space(data)
end)

# [%{longitude: 24.77162, latitude: 59.43877, status: "Available", zone_id: 1},
#  %{longitude: 24.77177, latitude: 59.43894, status: "Booked", zone_id: 2},
#  %{longitude: 24.77177, latitude: 59.43894, status: "Available", zone_id: 2},
#  %{longitude: 0.42, latitude: 0.30, status: "Available", zone_id: 2},
# %{longitude: 0.1, latitude: 0.1, status: "Available", zone_id: 2}]
# |> Enum.map(fn space_data -> Space.changeset(%Space{}, space_data) end)
# |> Enum.each(fn changeset -> Repo.insert!(changeset) end)


