defmodule ParkingWeb.Api.BookingControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.Repo
  alias Parking.Guardian
  alias Parking.Accounts.User
  alias Parking.Sales.Space
  alias Parking.Sales.Zone
  alias Parking.Sales.Allocation

  setup do
    user = Repo.get!(User, 1)
    {:ok, token, _claims} = Parking.Guardian.encode_and_sign(user)
    conn = build_conn() |> put_req_header("authorization", "Bearer #{token}")
    {:ok, conn: conn, user: user}
  end

  test "calculate price - not enough credit", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    # change account balance to zero
    presentUser = Repo.get!(User, 1)
    changedUser = User.changeset(presentUser, %{account_balance: 0.0})

    newuser = Repo.update(changedUser)

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/calculate_price", %{
        "start_time" => "2019-11-25 21:11:00",
        "end_time" => "2019-11-25 23:11:00",
        "space_id" => 1,
        "is_hourly" => true
      })

    expectedResult = %{
      "end_time" => "2019-11-25 23:11:00",
      "price" => 2.0,
      "start_time" => "2019-11-25 21:11:00",
      "is_hourly" => true,
      "msg" => "You don't have enough credit!",
      "space_id" => 1,
      "zone" => "A"
    }

    assert expectedResult == json_response(conn, 200)
  end

  test "calculate price - enough credit", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/calculate_price", %{
        "start_time" => "2019-11-25 21:11:00",
        "end_time" => "2019-11-25 23:11:00",
        "space_id" => 1,
        "is_hourly" => true
      })

    expectedResult = %{
      "end_time" => "2019-11-25 23:11:00",
      "price" => 2.0,
      "start_time" => "2019-11-25 21:11:00",
      "is_hourly" => true,
      "msg" => "OK",
      "space_id" => 1,
      "zone" => "A"
    }

    assert expectedResult == json_response(conn, 200)
  end

  test "calculate price - negative time period", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    # change account balance to zero
    presentUser = Repo.get!(User, 1)
    changedUser = User.changeset(presentUser, %{account_balance: 0.0})

    newuser = Repo.update(changedUser)

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/calculate_price", %{
        "start_time" => "2019-11-25T23:11:00",
        "end_time" => "2019-11-25T21:11:00",
        "space_id" => 1,
        "is_hourly" => true
      })

    expectedResult = %{
      "msg" => "The end time should be ahead of start time!",
      "end_time" => "2019-11-25T21:11:00",
      "is_hourly" => true,
      "price" => 0,
      "space_id" => 1,
      "start_time" => "2019-11-25T23:11:00",
      "zone" => "?"
    }

    assert expectedResult == json_response(conn, :method_not_allowed)
  end

  test "create booking - hourly payment - negative", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/book_location", %{
        "start_time" => "2019-11-25 17:11:00",
        "end_time" => "2019-11-25 21:11:00",
        "space_id" => 1,
        "is_hourly" => true,
        "price" => -57.00
      })

    expectedResult = %{"msg" => "Price cannot be negative value!"}

    assert expectedResult == json_response(conn, :method_not_allowed)
  end

  test "create booking - hourly payment - positive", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/book_location", %{
        "start_time" => "2019-11-25 21:11:00",
        "end_time" => "2019-11-25 23:11:00",
        "space_id" => 1,
        "is_hourly" => true,
        "price" => 40.00
      })

    expectedResult = %{
      "allocation_status" => "active",
      "end_time" => "2019-11-25 23:11:00",
      "price" => 40.0,
      "start_time" => "2019-11-25 21:11:00",
      "zone" => "A"
    }

    assert expectedResult == json_response(conn, 200)
  end

  test "create booking - minute payment - negative", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/book_location", %{
        "start_time" => "2019-11-25 05:11:00",
        "end_time" => "2019-11-25 07:11:00",
        "space_id" => 1,
        "is_hourly" => false,
        "price" => -40.00
      })

    expectedResult = %{"msg" => "Price cannot be negative value!"}

    assert expectedResult == json_response(conn, :method_not_allowed)
  end

  test "create booking - minute payment - positive", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    conn =
      post(conn, "/api/book_location", %{
        "start_time" => "2019-11-25 21:11:00",
        "end_time" => "2019-11-25 23:11:00",
        "space_id" => 1,
        "is_hourly" => false,
        "price" => 40.00
      })

    expectedResult = %{
      "allocation_status" => "active",
      "end_time" => "2019-11-25 23:11:00",
      "price" => 40.0,
      "start_time" => "2019-11-25 21:11:00",
      "zone" => "A"
    }

    assert expectedResult == json_response(conn, 200)
  end

  # ====== 4th Iteration ============================================
  test "extend booking - hourly payment - negative", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    # create user
    changeset =
      User.changeset(%User{}, %{
        username: "test",
        password: "test123",
        name: "test",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # Get Token to add to request
    conn =
      post(conn, "/api/sessions", %{
        username: "test",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    conn1 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", %{
        "start_time" => "2019-11-25 18:11:00",
        "end_time" => "2019-11-25 20:11:00",
        "space_id" => 1,
        "is_hourly" => true,
        "price" => 40.00
      })

    # allocation_id

    allocations = Repo.all(Allocation, space_id: 1)
    allocation_count = Enum.count(allocations)
    allocation = Enum.at(allocations, allocation_count - 1)

    conn2 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/extend_hour_parking", %{
        "end_time" => "2019-11-25 19:11:00",
        "allocation_id" => allocation.id
      })

    #  "end_time" => "2019-11-25 20:11:00",

    expectedResult = %{"msg" => "New extension should be longer than previous"}

    assert expectedResult == Map.delete(json_response(conn2, 200), "user_id")
  end

  test "extend booking - hourly payment - positive", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    # create user
    changeset =
      User.changeset(%User{}, %{
        username: "test",
        password: "test123",
        name: "test",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # Get Token to add to request
    conn =
      post(conn, "/api/sessions", %{
        username: "test",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    conn1 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", %{
        "start_time" => "2019-11-25 18:11:00",
        "end_time" => "2019-11-25 20:11:00",
        "space_id" => 1,
        "is_hourly" => true,
        "price" => 40.00
      })

    # allocation_id

    allocations = Repo.all(Allocation, space_id: 1)
    allocation_count = Enum.count(allocations)
    allocation = Enum.at(allocations, allocation_count - 1)

    conn2 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/extend_hour_parking", %{
        "end_time" => "2019-11-25 22:11:00",
        "allocation_id" => allocation.id
      })

    #  "end_time" => "2019-11-25 20:11:00",

    expectedResult = %{
      "end_time" => "2019-11-25T22:11:00",
      "is_hourly" => true,
      "msg" => "OK",
      "space_id" => 1,
      "zone" => "A",
      "price" => 4.0,
      "start_time" => "2019-11-25T18:11:00.000000"
    }

    assert expectedResult == Map.delete(json_response(conn2, 200), "user_id")
  end

  test "end_parking - minute - positive", %{conn: conn} do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    # create user
    changeset =
      User.changeset(%User{}, %{
        username: "test",
        password: "test123",
        name: "test",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # Get Token to add to request
    conn =
      post(conn, "/api/sessions", %{
        username: "test",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    booking_data = %{
      "start_time" => "2019-11-25 18:11:00",
      "end_time" => "2019-11-25 20:11:00",
      "space_id" => 1,
      "is_hourly" => false,
      "price" => 40.00
    }

    conn1 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", booking_data)

    allocations = Repo.all(Allocation, space_id: 1)
    allocation_count = Enum.count(allocations)
    allocation = Enum.at(allocations, allocation_count - 1)

    conn2 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/end_parking", %{
        "space_id" => booking_data["space_id"]
      })

    #  "end_time" => "2019-11-25 20:11:00",

    expectedResult = %{"space_id" => 1}

    assert expectedResult == json_response(conn2, 200)
  end

  test "Trying to create active parking for One user throw exceptionand got http status 400", %{
    conn: conn
  } do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    # space 1
    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    # space 2
    Repo.insert!(%Space{
      id: 2,
      longitude: 26.705402,
      latitude: 58.386141,
      status: "Available",
      zone_id: zone_id
    })

    # create user1
    changeset =
      User.changeset(%User{}, %{
        username: "test",
        password: "test123",
        name: "test",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # create user2
    changeset =
      User.changeset(%User{}, %{
        username: "test2",
        password: "test123",
        name: "test2",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # Get Token to add to request
    conn =
      post(conn, "/api/sessions", %{
        username: "test",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    # data to post for booking
    booking_data = %{
      "start_time" => "2019-11-25 18:11:00",
      "end_time" => "2019-11-25 20:11:00",
      "space_id" => 1,
      "is_hourly" => false,
      "price" => 40.00
    }

    # Book a space user with name test
    conn1 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", booking_data)

    # conn =
    #   post(conn, "/api/sessions", %{
    #     username: "test2",
    #     password: "test123"
    #   })

    # assert json_response(conn, 201)
    # token = json_response(conn, 201)["token"]

    # using another space date to create booking
    booking_data = %{
      "start_time" => "2019-11-25 18:11:00",
      "end_time" => "2019-11-25 20:11:00",
      "space_id" => 2,
      "is_hourly" => false,
      "price" => 40.00
    }

    #using the same token that just created a booking
    conn2 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", booking_data)


    expectedResult = %{"msg" => "Cant Have two active Parking"}

    assert expectedResult == json_response(conn2, 400)
  end

  test "Trying to create active parking for Two different user works and got 200(:ok)", %{
    conn: conn
  } do
    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    # space 1
    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    # space 2
    Repo.insert!(%Space{
      id: 2,
      longitude: 26.705402,
      latitude: 58.386141,
      status: "Available",
      zone_id: zone_id
    })

    # create user1
    changeset =
      User.changeset(%User{}, %{
        username: "test",
        password: "test123",
        name: "test",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # create user2
    changeset =
      User.changeset(%User{}, %{
        username: "test2",
        password: "test123",
        name: "test2",
        role: "CLIENT",
        email: "customer@ut.ee",
        account_balance: 1000.00
      })

    Repo.insert!(changeset)

    # Get Token to add to request for first booking
    conn =
      post(conn, "/api/sessions", %{
        username: "test",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

   #booking data for the 1st booking
    booking_data = %{
      "start_time" => "2019-11-25 18:11:00",
      "end_time" => "2019-11-25 20:11:00",
      "space_id" => 1,
      "is_hourly" => false,
      "price" => 40.00
    }

    # Book a space user with name test
    conn1 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", booking_data)

    conn =
      post(conn, "/api/sessions", %{
        username: "test2",
        password: "test123"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    #booking data for the 2nd booking
    booking_data = %{
      "start_time" => "2019-11-25 18:11:00",
      "end_time" => "2019-11-25 20:11:00",
      "space_id" => 2,
      "is_hourly" => false,
      "price" => 40.00
    }

    #using a new token for user2 create a new booking
    conn2 =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/book_location", booking_data)

    expectedResult = %{
      "allocation_status" => "active",
      "end_time" => "2019-11-25 20:11:00",
      "price" => 40.0,
      "start_time" => "2019-11-25 18:11:00",
      "zone" => "A"
    }

    assert expectedResult == json_response(conn2, 200)
  end

  test "Register parking for monthly payment", %{} do
    conn =
      post(conn, "/api/sessions", %{
        username: "fred",
        password: "parool"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Booked",
      zone_id: zone_id
    })

    space = Repo.all(Space, status: "Booked")
    space_id = Enum.at(space, 0).id

    allocation = Allocation.changeset(%Allocation{}, %{
      start_time: "2019-12-02 10:00:00",
      end_time: "2019-12-02 12:00:00",
      is_hourly: false,
      user_id: 1,
      space_id: space_id,
      allocation_status: "active"
    })
    Repo.insert!(allocation)

    conn = build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/register_parking_for_monthly_payment", %{
        "start_time" => "2019-12-02 10:00:00",
        "end_time" => "2019-12-02 12:00:00",
        "space_id" => space_id,
        "is_hourly" => false
      })

    expectedResult = %{
      "start_time" => "2019-12-02 10:00:00",
      "end_time" => "2019-12-02 12:00:00",
      "space_id" => space_id,
      "is_hourly" => false
    }

    assert expectedResult == json_response(conn, 200)
  end

  test "Pay monthly payment", %{} do
    conn =
      post(conn, "/api/sessions", %{
        username: "fred",
        password: "parool"
      })

    assert json_response(conn, 201)
    token = json_response(conn, 201)["token"]

    changeset = Zone.changeset(%Zone{}, %{zone_type: "A", hourly_rate: 1, real_time_rate: 0.08})
    Repo.insert!(changeset)

    zone = Repo.all(Zone, zone_type: "A")
    zone_id = Enum.at(zone, 0).id

    Repo.insert!(%Space{
      id: 1,
      longitude: 26.717613,
      latitude: 58.379588,
      status: "Available",
      zone_id: zone_id
    })

    space = Repo.all(Space, status: "Available")
    space_id = Enum.at(space, 0).id

    allocation = Allocation.changeset(%Allocation{}, %{
      start_time: "2019-12-02 10:00:00",
      end_time: "2019-12-02 12:00:00",
      is_hourly: false,
      user_id: 1,
      space_id: space_id,
      allocation_status: "Unpaid"
    })
    Repo.insert!(allocation)

    conn = build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/pay_monthly_payment", %{
        "total" => 50
      })

    expectedResult = %{
      "total" => 50
    }

    assert expectedResult == json_response(conn, 200)
  end
end
