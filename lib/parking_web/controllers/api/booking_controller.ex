defmodule ParkingWeb.Api.BookingController do
  use ParkingWeb, :controller

  alias Parking.AccessLayer.BookSpace
  alias Parking.AccessLayer.SearchSpace
  alias Parking.Authentication
  alias Parking.Sales.Allocation
  alias Parking.Sales.Processcontrol
  alias Parking.Repo
  alias Parking.Sales.Space
  alias Ecto.Changeset
  alias Parking.AccessLayer.Mailer

  import Ecto.Query, only: [from: 2]

  def create_booking(conn, %{
        "start_time" => start_time,
        "end_time" => end_time,
        "space_id" => space_id,
        "is_hourly" => is_hourly,
        "price" => price
      }) do
    user = Authentication.load_current_user(conn)
    start_time = NaiveDateTime.from_iso8601!(start_time)

    end_time =
      if end_time do
        NaiveDateTime.from_iso8601!(end_time)
      else
        end_time
      end


    
    from(p in Processcontrol, where: p.status == true and p.user_id ==^user.id) |> Repo.delete_all
    # to convert int into float
    price =
      if price do
        price / 1
      else
        price
      end

    cond do
      price < 0 ->
        conn
        |> put_status(:method_not_allowed)
        |> json(%{msg: "Price cannot be negative value!"})

      true ->
        space = SearchSpace.get_space!(space_id)

        updateResult =
          Space.changeset(space)
          |> Changeset.put_change(:status, "Booked")
          |> Changeset.put_change(:user_id, user.id)
          |> Repo.update()

        case updateResult do
          # Ecto.ConstraintError ->

          {:ok, _} ->
            user_details = BookSpace.get_user!(user.id)
            changeset =
            (
              if price do
                Allocation.changeset(
                  %Allocation{
                    allocation_status: "active",
                    start_time: start_time,
                    end_time: end_time,
                    price: price,
                    user_id: user.id,
                    space_id: space_id,
                    is_hourly: is_hourly
                  },
                  %{}
                )
              else
                Allocation.changeset(
                  %Allocation{
                    allocation_status: "active",
                    start_time: start_time,
                    end_time: end_time,
                    user_id: user.id,
                    space_id: space_id,
                    is_hourly: is_hourly
                  },
                  %{}
                )
              end
            )

            if price do
                new_balance = user_details.account_balance - price
                user_attrs = %{"account_balance" => new_balance}
                BookSpace.update_user_balance(user_details, user_attrs)
            end

              if price do
                new_balance = user_details.account_balance - price
                user_attrs = %{"account_balance" => new_balance}
                BookSpace.update_user_balance(user_details, user_attrs)
              end

            # Send notification

            if is_hourly == true do
              name = user.name
              start_time_string = to_string(start_time)
              end_time_string = to_string(end_time)

              mail_text_now =
                "<h4>Dear " <>
                  name <>
                  "</h4> <p><strong>This is to inform you that you have active booking from " <>
                  start_time_string <>
                  " to " <>
                  end_time_string <>
                  ".</strong></p> <p>We will also remind you 10 minutes before the end time so you can get ready to vacate the space</p> <p>Thank you,</p><p>Sola from Parking</p>"

              mail_text_later =
                "<h4>Dear " <>
                  name <>
                  "</h4> <p><strong>This is to inform you that your booking ends by " <>
                  end_time_string <>
                  ".</strong></p> <p>Kindly get ready to vacate the space. For extending your parking period please log into your account and extend it.</p> <p>Thank you,</p><p>Sola from Parking</p>"

              # ten_minute_before = NaiveDateTime.add(end_time, -600)
              unix_time =
                NaiveDateTime.diff(NaiveDateTime.add(end_time, -7800), ~N[1970-01-01 00:00:00])
              exec_time_in_millisecond = 
                NaiveDateTime.diff(NaiveDateTime.add(end_time, -120), NaiveDateTime.add(NaiveDateTime.utc_now(), 7200), :millisecond)
          
             
          
              Mailer.send_mail_now(user.email, mail_text_now)
              Mailer.send_mail_later(user.email, mail_text_later, unix_time)

              space = SearchSpace.get_space!(space_id)
              space_attrs = %{"status" => "Available", "user_id" => nil}


              space_pid_name = spawn(fn -> :timer.sleep(exec_time_in_millisecond); BookSpace.update_space(space, space_attrs) end)
              space_process_status =  Process.alive?(space_pid_name)
              space_process_attrs = %{"pid" => Kernel.inspect(space_pid_name), "status"=> space_process_status, "pid_name"=> "space process", "user_id" => user.id}
              space_process_param= BookSpace.create_process(space_process_attrs)
              IO.inspect(exec_time_in_millisecond)
            end

            case Repo.insert(changeset) do
              {:ok, booking_param} ->

                st = NaiveDateTime.to_string(start_time)
                et =
                if end_time do
                  NaiveDateTime.to_string(end_time)
                else
                  end_time
                end
                
              if is_hourly==true do
              allo_exec_time_in_millisecond = 
              NaiveDateTime.diff(end_time, NaiveDateTime.add(NaiveDateTime.utc_now(), 7200), :millisecond)
              allo = BookSpace.get_allocation!(booking_param.id)
              allo_attrs = %{"allocation_status" => "Closed"}
              allo_pid_name = spawn(fn -> :timer.sleep(allo_exec_time_in_millisecond); BookSpace.update_allocation(allo, allo_attrs) end)
              allo_process_status =  Process.alive?(allo_pid_name)
              allo_process_attrs = %{"pid" => Kernel.inspect(allo_pid_name), "status"=> allo_process_status, "pid_name"=> "allocation process", "user_id" => user.id}
              allo_process_param= BookSpace.create_process(allo_process_attrs)
    
              end  
               
              conn
                |> put_status(:ok)
                |> json(%{
                  allocation_status: "active",
                  start_time: st,
                  end_time: et,
                  price: price,
                  zone: space.zone.zone_type
                })

              {:error, _} ->
                conn
                |> put_status(400)
                |> json(%{msg: "Error"})
            end

          {:error, error} ->
            conn
            |> put_status(400)
            |> json(%{msg: "Cant Have two active Parking"})
        end
    end
  end

  def calculate_price(
        conn,
        allocation_params = %{
          "start_time" => start_time,
          "end_time" => end_time,
          "space_id" => space_id,
          "is_hourly" => is_hourly
        }
      ) do
    user = Authentication.load_current_user(conn)

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

        conn
        |> put_status(:method_not_allowed)
        |> json(allocation_params)

      true ->
        duration = time_range_in_second / 3600

        space = SearchSpace.get_space!(space_id)
        zone = space.zone.zone_type

        price = space.zone.hourly_rate * duration

        user_details = BookSpace.get_user!(user.id)

        if user_details.account_balance >= price do
          # Calculating new balance
          allocation_params =
            allocation_params
            |> Map.put("price", price)
            |> Map.put("zone", zone)
            |> Map.put("msg", "OK")

          conn
          |> put_status(:ok)
          |> json(allocation_params)
        else
          allocation_params =
            allocation_params
            |> Map.put("price", price)
            |> Map.put("zone", zone)
            |> Map.put("msg", "You don't have enough credit!")

          conn
          |> put_status(:ok)
          |> json(allocation_params)
        end
    end
  end

  def get_user_active_allocations(conn, _params) do
    user = Authentication.load_current_user(conn)

    query =
      from(a in Allocation,
        where: a.user_id == ^user.id,
        where: a.allocation_status == "active",
        select: %{
          start_time: a.start_time,
          end_time: a.end_time,
          is_hourly: a.is_hourly,
          price: a.price,
          space_id: a.space_id,
          allocation_id: a.id
        }
      )

    allocations = Repo.all(query)

    if length(allocations) > 0 do
      allocation = Enum.at(allocations, 0)

      space = SearchSpace.get_space!(allocation.space_id)
      zone = space.zone.zone_type

      st = NaiveDateTime.to_string(allocation.start_time)
      et =
      if allocation.end_time do
        NaiveDateTime.to_string(allocation.end_time)
      else
        allocation.end_time
      end

      allocation_params = %{
        "space_id" => space.id,
        "start_time" => st,
        "end_time" => et,
        "zone" => zone,
        "allocation_id" => allocation.allocation_id,
        "is_hourly" => allocation.is_hourly,
        "msg" => "OK"
      }

      conn
      |> put_status(:ok)
      |> json(allocation_params)
    else
      allocation_params = %{"msg" => "No active allocations"}

      conn
      |> put_status(:ok)
      |> json(allocation_params)
    end
  end

  def end_parking(
        conn,
        params = %{
          "space_id" => space_id
        }
      ) do
    user = Authentication.load_current_user(conn)

    query =
      from(a in Allocation,
        where: a.user_id == ^user.id,
        where: a.allocation_status == "active",
        select: %{allocation_id: a.id, user_id: a.user_id}
      )

    allocations = Repo.all(query)
    allocation = Enum.at(allocations, 0)

    a = Repo.get!(Allocation, allocation.allocation_id)

    Allocation.changeset(a)
    |> Changeset.put_change(:allocation_status, "closed")
    |> Repo.update()

    space = SearchSpace.get_space!(space_id)

    Space.changeset(space)
    |> Changeset.put_change(:status, "Available")
    |> Changeset.put_change(:user_id, nil)
    |> Repo.update()

    conn
    |> put_status(:ok)
    |> json(params)
  end

  def register_parking_for_monthly_payment(conn, params = %{
                                  "start_time" => start_time,
                                  "end_time" => end_time,
                                  "space_id" => space_id,
                                  "is_hourly" => is_hourly
  }) do
    user = Authentication.load_current_user(conn)

    query =
      from(a in Allocation,
        where: a.user_id == ^user.id,
        where: a.allocation_status == "active",
        select: %{allocation_id: a.id, user_id: a.user_id}
      )

    allocations = Repo.all(query)
    allocation = Enum.at(allocations, 0)

    a = Repo.get!(Allocation, allocation.allocation_id)

    start_time = NaiveDateTime.from_iso8601!(start_time)
    end_time = NaiveDateTime.from_iso8601!(end_time)
    time_range_in_second = NaiveDateTime.diff(end_time, start_time)

    cond do
      time_range_in_second < 0 ->
        params =
          params
          |> Map.put("price", 0)
          |> Map.put("zone", "?")
          |> Map.put("msg", "The end time should be ahead of start time!")

        conn
        |> put_status(:method_not_allowed)
        |> json(params)

      true ->
        duration = time_range_in_second / 3600

        space = SearchSpace.get_space!(space_id)
        zone = space.zone.zone_type

        price = space.zone.hourly_rate * duration

      IO.puts(price)

    Allocation.changeset(a)
    |> Changeset.put_change(:allocation_status, "Unpaid")
    |> Changeset.put_change(:end_time, end_time)
    |> Changeset.put_change(:price, price)
    |> Repo.update()

    space = SearchSpace.get_space!(space_id)

    Space.changeset(space)
    |> Changeset.put_change(:user_id, nil)
    |> Changeset.put_change(:status, "Available")
    |> Repo.update()

    conn
    |> put_status(:ok)
    |> json(params)

  end
  end

  def pay_monthly_payment(conn, params = %{"total" => total}) do
    user = Authentication.load_current_user(conn)

    query =
      from(a in Allocation,
        where: a.user_id == ^user.id,
        where: a.allocation_status == "Unpaid",
        select: %{allocation_id: a.id, user_id: a.user_id, start_time: a.start_time, end_time: a.end_time, price: a.price}
      )

    allocations = Repo.all(query)

    Enum.each allocations, fn(allocation) ->
      a = Repo.get!(Allocation, allocation.allocation_id)
      Allocation.changeset(a) |> Changeset.put_change(:allocation_status, "Closed") |> Repo.update()
    end

    user_details = BookSpace.get_user!(user.id)
    new_balance = user_details.account_balance - total
    user_attrs = %{"account_balance" => new_balance}
    BookSpace.update_user_balance(user_details, user_attrs)

    conn
    |> put_status(:ok)
    |> json(params)

  end

  def get_unpaid_allocations(conn, %{}) do
    user = Authentication.load_current_user(conn)

    query =
      from(a in Allocation,
        where: a.user_id == ^user.id,
        where: a.allocation_status == "Unpaid",
        select: %{allocation_id: a.id, user_id: a.user_id, start_time: a.start_time, end_time: a.end_time, price: a.price}
      )

      allocations = Repo.all(query)

      prices = Enum.map(allocations, &(&1.price))

      total = Enum.sum(prices)

     params = %{}

      params =
            params
            |> Map.put("total", total)
            |> Map.put("unpaid_allocations", allocations)

      conn
      |> put_status(:ok)
      |> json(params)

  end

  def extend_parking(conn, %{
        "end_time" => end_time,
        "allocation_id" => allocation_id
      }) do
    user = Authentication.load_current_user(conn)
    allocation = BookSpace.get_allocation!(allocation_id)

    end_time = NaiveDateTime.from_iso8601!(end_time)
    end_time_diff = NaiveDateTime.diff(end_time, allocation.end_time)

     space_query = from p in Processcontrol,
        where: p.user_id ==  ^user.id,
        where: p.status == true,
        where: p.pid_name == "space process",
        select: %{process_id: p.id, pid: p.pid}

     allo_query = from p in Processcontrol,
        where: p.user_id ==  ^user.id,
        where: p.status == true,
        where: p.pid_name == "allocation process",
        select: %{process_id: p.id, pid: p.pid}

    space_processes = Repo.all(space_query)
    space_process = Enum.at(space_processes, 0) 
    space_process_name = space_process.pid
    space_process_name= String.replace space_process_name, "#PID", ""
    space_process_name = String.to_charlist(space_process_name)
    space_process_params = Repo.get!(Processcontrol, space_process.process_id)
   
    space_pid = :erlang.list_to_pid(space_process_name)

    allo_processes = Repo.all(allo_query)
    allo_process = Enum.at(allo_processes, 0) 
    allo_process_name = allo_process.pid
    allo_process_name= String.replace allo_process_name, "#PID", ""
    allo_process_name = String.to_charlist(allo_process_name)
    allo_process_params = Repo.get!(Processcontrol, allo_process.process_id)
   
    allo_pid = :erlang.list_to_pid(allo_process_name)

    if end_time_diff > 0 do
      current_price = allocation.price

      new_price_data =
        BookSpace.calculate_price(
          allocation_params = %{
            "user_id" => allocation.user_id,
            "start_time" => allocation.start_time,
            "end_time" => end_time,
            "space_id" => allocation.space_id,
            "is_hourly" => allocation.is_hourly
          }
        )

      new_calculated_price = new_price_data["price"]
      amount_to_pay = new_calculated_price - current_price

      user_details = BookSpace.get_user!(allocation.user_id)

      if new_price_data["msg"] == "OK" do
        new_balance = user_details.account_balance - amount_to_pay
        user_attrs = %{"account_balance" => new_balance}
        BookSpace.update_user_balance(user_details, user_attrs)
        allocation_attrs = %{"end_time" => end_time, "price" => new_calculated_price}
        BookSpace.update_allocation(allocation, allocation_attrs)

        #Space process update
        space = SearchSpace.get_space!(allocation.space_id)
        space_attrs = %{"status" => "Available", "user_id" => nil}
        exec_time_in_millisecond = NaiveDateTime.diff(NaiveDateTime.add(end_time, -120),  NaiveDateTime.add(NaiveDateTime.utc_now(), 7200), :millisecond)
        Process.exit(space_pid, :ok)
        space_pid_new =  spawn(fn -> :timer.sleep(exec_time_in_millisecond); BookSpace.update_space(space, space_attrs) end)
        update_process = BookSpace.update_process(space_process_params, %{"pid"=> Kernel.inspect(space_pid_new)})
       
        #Allocation process update
        allo_attrs = %{"allocation_status" => "Closed"}
        allo_exec_time_in_millisecond = NaiveDateTime.diff(end_time, NaiveDateTime.add(NaiveDateTime.utc_now(), 7200), :millisecond)
        Process.exit(allo_pid, :ok)
        allo_pid_new =  spawn(fn -> :timer.sleep(allo_exec_time_in_millisecond); BookSpace.update_allocation(allocation, allo_attrs) end)
        update_process = BookSpace.update_process(allo_process_params, %{"pid"=> Kernel.inspect(allo_pid_new)})
     
      end

      conn
      |> put_status(:ok)
      |> json(new_price_data)
    else
      conn
      |> put_status(:ok)
      |> json(%{"msg" => "New extension should be longer than previous"})
    end
  end
end
