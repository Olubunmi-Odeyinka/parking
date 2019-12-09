defmodule ParkingWeb.Api.SearchSpaceController do
  use ParkingWeb, :controller

  alias Parking.AccessLayer.SearchSpace
  alias Parking.AccessLayer.Geolocation
  alias Parking.AccessLayer.Mailer

  def find_space(conn, %{"location" => location, "intended_hour" => intended_hour}) do
    long_lat = Geolocation.find_location(location)
    space = SearchSpace.search_space(Enum.at(long_lat, 0), Enum.at(long_lat, 1))

    if Enum.count(space) >= 1 do
      cond do
        intended_hour != "" ->
          intended_hour = String.to_integer(intended_hour)

          space_transform = %{
            "available_space" =>
              Enum.map(space, fn x ->
                %{
                  "id" => x.id,
                  "zone" => x.zone.zone_type,
                  "calculated_hourly_rate" => x.zone.hourly_rate * intended_hour,
                  "calculated_real_time_rate" => x.zone.real_time_rate * (60 * intended_hour) / 5,
                  "zone_hourly_rate" => x.zone.hourly_rate,
                  "zone_real_time_rate" => x.zone.real_time_rate,
                  "status" => x.status,
                  "latitude" => x.latitude,
                  "longitude" => x.longitude
                }
              end)
          }

          conn
          |> put_status(:ok)
          |> json(space_transform)

        true ->
          space_transform = %{
            "available_space" =>
              Enum.map(space, fn x ->
                %{
                  "id" => x.id,
                  "zone" => x.zone.zone_type,
                  "status" => x.status,
                  "latitude" => x.latitude,
                  "longitude" => x.longitude,
                  "zone_hourly_rate" => x.zone.hourly_rate,
                  "zone_real_time_rate" => x.zone.real_time_rate
                }
              end)
          }

          conn
          |> put_status(:ok)
          |> json(space_transform)
      end
    else
      conn
      |> put_status(200)
      |> json(%{msg: "No available space in your zone"})
    end
end
end
