defmodule ParkingWeb.Api.SessionControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.{Accounts.User, Repo}
  alias Parking.Guardian

  test "Session creation - negative", %{conn: conn} do
    conn = post(conn, "/api/sessions", %{username: "test", password: "test123"})

    assert json_response(conn, 400) == %{
             "message" => "Bad credentials"
           }

    conn = post(conn, "/api/find_location", %{location: "Lossi 2, Tartu", intended_hour: "2"})
    assert response(conn, 401) == "{\"error\":\"unauthenticated\"}"
  end

  test "Session creation - positive", %{conn: conn} do
    changeset =
      User.changeset(%User{}, %{
        username: "test",
        password: "test123",
        name: "test",
        role: "CLIENT",
        email: "customer@ut.ee"
      })

    Repo.insert!(changeset)

    conn =
      post(conn, "/api/sessions", %{
        username: "test",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/find_location", %{location: "Lossi 2, Tartu", intended_hour: "2"})

    assert response(conn, 200) == "{\"msg\":\"No available space in your zone\"}"
  end

  test "Session deleting", %{conn: conn} do
    conn = delete(conn, "/api/sessions/1", %{})
    assert response(conn, 401) == "{\"error\":\"unauthenticated\"}"

    conn = post(conn, "/api/find_location", %{location: "Lossi 2, Tartu", intended_hour: "2"})

    assert response(conn, 401) == "{\"error\":\"unauthenticated\"}"
  end
end
