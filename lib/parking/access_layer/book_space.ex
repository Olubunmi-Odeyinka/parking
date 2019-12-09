defmodule Parking.AccessLayer.BookSpace do
  import Ecto.Query, only: [from: 2]
  alias Parking.Repo
  alias Parking.Sales.Allocation
  alias Parking.Sales.Space
  alias Parking.Sales.Processcontrol
  alias Parking.Accounts.User
  alias Parking.AccessLayer.SearchSpace

  def create_allocation(attrs \\ %{}) do
    %Allocation{}
    |> Allocation.changeset(attrs)
    |> Repo.insert()
  end
def create_process(attrs \\ %{}) do
    %Processcontrol{}
      |> Processcontrol.changeset(attrs)
      |> Repo.insert()
  end

    def update_process(%Processcontrol{} = process, attrs) do
    process
    |> Processcontrol.changeset(attrs)
    |> Repo.update()
  end
  def update_space(%Space{} = space, attrs) do
    space
    |> Space.changeset(attrs)
    |> Repo.update()
  end

  def update_allocation(%Allocation{} = allocation, attrs) do
    allocation
    |> Allocation.changeset(attrs)
    |> Repo.update()
  end

  def update_user_balance(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_allocation!(id), do: Repo.get!(Allocation, id)

  def calculate_price(allocation_params) do
    start_time = to_string(allocation_params["start_time"])
    end_time = to_string(allocation_params["end_time"])
    start_time = NaiveDateTime.from_iso8601!(start_time)
    end_time = NaiveDateTime.from_iso8601!(end_time)

    time_range_in_second = NaiveDateTime.diff(end_time, start_time)

    cond do
      time_range_in_second < 0 ->
        allocation_params =
          allocation_params
          |> Map.put("price", 0)
          |> Map.put("zone", "?")
          |> Map.put("msg", "The end time should be ahead of start time!")

      true ->
        duration = time_range_in_second / 3600

        space = SearchSpace.get_space!(allocation_params["space_id"])
        zone = space.zone.zone_type

        price = Float.ceil(space.zone.hourly_rate * duration, 2)

        user_details = get_user!(allocation_params["user_id"])

        if user_details.account_balance >= price do
          allocation_params =
            allocation_params
            |> Map.put("price", price)
            |> Map.put("zone", zone)
            |> Map.put("msg", "OK")
        else
          allocation_params =
            allocation_params
            |> Map.put("price", price)
            |> Map.put("zone", zone)
            |> Map.put("msg", "You don't have enough credit!")
        end
    end
  end
end
