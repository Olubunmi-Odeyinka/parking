defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias Parking.{Repo, Accounts.User}

  feature_starting_state(fn ->
    Application.ensure_all_started(:hound)
    %{}
  end)

  scenario_starting_state(fn state ->
    Hound.start_session()
    Ecto.Adapters.SQL.Sandbox.checkout(Parking.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Parking.Repo, {:shared, self()})
    %{}
  end)

  scenario_finalize(fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo)
    Hound.end_session()
  end)

  given_(~r/^the following users are registered$/, fn state, %{table_data: table} ->
    table
    |> Enum.map(fn user -> User.changeset(%User{}, user) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    {:ok, state}
  end)

  when_(
    ~r/^I navigate to "(?<argument_one>[^"]+)" i.e. "(?<argument_two>[^"]+)"$/,
    fn state, %{argument_one: _argument_one, argument_two: _url} ->
      navigate_to(_url)
      {:ok, state}
    end
  )

  and_(
    ~r/^I fill my credentials as username "(?<argument_one>[^"]+)" and password "(?<argument_two>[^"]+)"$/,
    fn state, %{argument_one: _username, argument_two: _password} ->
      fill_field({:id, "username"}, _username)
      fill_field({:id, "password"}, _password)
      {:ok, state}
    end
  )

  when_(
    ~r/^I click "(?<argument_one>[^"]+)" Button with "(?<argument_two>[^"]+)" "(?<argument_three>[^"]+)"$/,
    fn state, %{argument_one: _argument_one, argument_two: _type, argument_three: _identifier} ->
      IO.inspect(_identifier)

      case _type do
        "class" ->
          res = find_element(:class, _identifier)
          # IO.inspect(res)
          case res do
            [tr1, _] ->
              tr1 |> click()

              {:ok, state}

            [tr1] ->
              tr1 |> click()

              {:ok, state}

            tr1 ->
              tr1 |> click()

              {:ok, state}

            true ->
              {:ok, state}
          end

        "id" ->
          res = find_element(:id, _identifier)
          #IO.inspect(res)

          case res do
            [tr1, _] ->
              tr1 |> click()

              {:ok, state}

            [tr1] ->
              tr1 |> click()

              {:ok, state}

            tr1 ->
              tr1 |> click()

              {:ok, state}

            true ->
              {:ok, state}
          end

        _ ->
          {:ok, state}
      end
    end
  )

  then_(~r/^I should be logged in$/, fn state ->
    assert wait_for(fn -> Regex.match?(~r/Done/, visible_page_text()) end)
    {:ok, state}
  end)

  def wait_for(func) do
    :timer.sleep(5000)

    case func.() do
      true -> true
      false -> false
    end
  end

  # then_(
  #   ~r/^I should get response with status "(?<argument_one>[^"]+)"$/,
  #   fn state  ->
  #     assert visible_in_page? ~r/done?/
  #     {:ok, state}
  #   end
  # )
end
