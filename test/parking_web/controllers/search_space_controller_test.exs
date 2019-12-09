defmodule ParkingWeb.Api.SearchSpaceControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.AccessLayer.SearchSpace
  alias Parking.Repo
  alias Parking.Sales.Zone
  alias Parking.Sales.Space
  alias Parking.Guardian
  alias Parking.Accounts.User

  import Ecto.Query, only: [from: 2]

  setup do
    user = Repo.get!(User, 1)
    {:ok, token, _claims} = Parking.Guardian.encode_and_sign(user)
    conn = build_conn() |> put_req_header("authorization", "Bearer #{token}")
    {:ok, conn: conn, user: user}
  end

  test "find space without intended hour - positive", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "B", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "B")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn = post(conn, "/api/find_location", %{location: "Riia 3, Tartu", intended_hour: ""})

    expected_response = %{
      "available_space" => [
        %{
          "id" => 5,
          "zone" => "B",
          "status" => "Available",
          "latitude" => 58.379588,
          "longitude" => 26.717613,
          "zone_hourly_rate" => 1,
          "zone_real_time_rate" => 0.08
        }
      ]
    }

    assert expected_response = json_response(conn, 200)
  end

  test "find space without intended hour - negative", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "B", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "B")
    zone_id = Enum.at(zone, 0).id

    allspaces = Repo.all(Space)

    Repo.insert!(%Space{
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Booked",
      zone_id: zone_id
    })

    conn = post(conn, "/api/find_location", %{location: "Riia 3, Tartu", intended_hour: ""})

    assert json_response(conn, 200) == %{
             "msg" => "No available space in your zone"
           }
  end

  test "find space with intended hour - positive", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "B", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "B")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn = post(conn, "/api/find_location", %{location: "Riia 3, Tartu", intended_hour: "2"})

    query =
      from(s in Space,
        where: s.status == "Available",
        select: %{id: s.id}
      )

    spaces = Repo.all(query)
    space_id = Enum.at(spaces, 0).id

    assert json_response(conn, 200) == %{
             "available_space" => [
               %{
                 "calculated_hourly_rate" => 2,
                 "calculated_real_time_rate" => 1.92,
                 "id" => space_id,
                 "latitude" => 58.379588,
                 "longitude" => 26.717613,
                 "status" => "Available",
                 "zone" => "B",
                 "zone_hourly_rate" => 1,
                 "zone_real_time_rate" => 0.08
               }
             ]
           }
  end

  test "find space with intended hour - negative", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "B", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "B")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Booked",
      zone_id: zone_id
    })

    conn = post(conn, "/api/find_location", %{location: "Riia 3, Tartu", intended_hour: "2"})

    assert json_response(conn, 200) == %{
             "msg" => "No available space in your zone"
           }
  end
end
