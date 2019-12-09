defmodule Parking.AccessLayer.SearchSpace do
  import Ecto.Query, only: [from: 2]
  alias Parking.Repo
  alias Parking.Accounts.User
  alias Parking.Sales.Space
  alias Parking.Sales.Zone
  alias :math, as: Math

  def create_space(attrs \\ %{}) do
    %Space{}
    |> Space.changeset(attrs)
    |> Repo.insert()
  end

  def create_zone(attrs \\ %{}) do
    %Zone{}
    |> Zone.changeset(attrs)
    |> Repo.insert()
  end

   def get_space!(id), do: Repo.get!(Space, id)
    |> Repo.preload([:zone])


  def search_space(lat, long) do
    # https://stackoverflow.com/questions/7477003/calculating-new-longitude-latitude-from-old-n-meters
    coef = 1000 * 0.0000089
    lat_max = lat + coef
    lat_min = lat - coef
    long_max = long + coef / Math.cos(lat * 0.018)
    long_min = long - coef / Math.cos(lat * 0.018)

    query =
      from(u in Space,
        where: u.latitude >= ^lat_min and
               u.latitude <= ^lat_max and
               u.longitude >= ^long_min and
               u.longitude <= ^long_max and
               u.status == "Available",
        preload: [:zone]
      )

    Repo.all(query)
  end
end
