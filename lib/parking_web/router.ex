defmodule ParkingWeb.Router do
  use ParkingWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :browser_auth do
    plug(Parking.AuthPipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)

  end

  scope "/", ParkingWeb do
    pipe_through [:browser]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/users", UserController, only: [:create]


  end

  scope "/", ParkingWeb do
    pipe_through([:browser, :browser_auth])
    get("/", PageController, :index)
    get("/parking", PageController, :index)
  end

  # scope "/", ParkingWeb.Api do
  #   pipe_through [:api]
  #   post  "/find_location", SearchSpaceController, :find_space
  # end
  # pipeline :api do
  #   plug(:accepts, ["json"])
  # end

  # scope "/", ParkingWeb do
  #   # Use the default browser stack
  #   pipe_through(:browser)

  #   get("/", PageController, :index)
  # end

  # Other scopes may use custom stacks.
  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth_api do
    plug(Parking.ApiAuthPipeline)
  end

  scope "/api", ParkingWeb.Api do
    pipe_through(:api)
    post("/sessions", SessionController, :create)
    post("/users", UserController, :create)
  end

  scope "/api", ParkingWeb.Api do
    pipe_through([:api, :auth_api])
    post("/find_location", SearchSpaceController, :find_space)
    post "/book_location", BookingController, :create_booking
    resources "/users", UserController
    delete("/sessions/:id", SessionController, :delete)
    post("/calculate_price", BookingController, :calculate_price)
    post("/save_monthly_plan", UserController, :save_monthly_plan)
    get("/get_monthly_payment", UserController, :get_monthly_payment)
    get("/get_allocations", BookingController, :get_user_active_allocations)
    post("/end_parking", BookingController, :end_parking)
    post("/register_parking_for_monthly_payment", BookingController, :register_parking_for_monthly_payment)
    post("/extend_hour_parking", BookingController, :extend_parking)
    get("/get_unpaid_allocations", BookingController, :get_unpaid_allocations)
    post("/pay_monthly_payment", BookingController, :pay_monthly_payment)
  end

   scope "/", ParkingWeb.Api do
    pipe_through [:browser]
    post "/book_location", BookingController, :create_booking
    post("/find_location", SearchSpaceController, :find_space)
  end
end
