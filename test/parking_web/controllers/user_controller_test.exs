defmodule ParkingWeb.Api.UserControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.{Accounts.User, Repo}

  test "User creation - negative", %{conn: conn} do
    user = Repo.all(User)
    nr_of_users = Enum.count(user)

    conn =
      post(conn, "/api/users", %{
        username: "test",
        password: "test",
        name: "test",
        role: "customer",
        email: "customer@ut.ee"
      })

    user_after = Repo.all(User)
    nr_of_users_after = Enum.count(user_after)
    assert nr_of_users == nr_of_users_after
  end

  test "User creation - positive", %{conn: conn} do
    user = Repo.all(User)
    nr_of_users = Enum.count(user)

    conn =
      post(conn, "/api/users", %{
        username: "test",
        password: "test123",
        name: "test name",
        role: "customer",
        email: "customer@ut.ee"
      })

    #  :valid_date, :cvv

    user_after = Repo.all(User)
    nr_of_users_after = Enum.count(user_after)
    assert nr_of_users + 1 == nr_of_users_after

    created_user = Repo.get_by(User, username: "test")
    created_username = created_user.username
    created_name = created_user.name
    created_role = created_user.role

    assert created_username == "test"
    assert created_name == "test name"
    assert created_role == "customer"
  end
end
