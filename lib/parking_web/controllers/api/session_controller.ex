defmodule ParkingWeb.Api.SessionController do
  use ParkingWeb, :controller
  alias Parking.{Repo, Accounts.User, Authentication, Guardian}

  def create(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)
    case Authentication.check_credentials(user, password) do
    {:ok, _} ->
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
        conn
        |> put_status(201)
        |> json(%{token: jwt, role: user.role})
    {:error, _} ->
        conn
        |> put_status(400)
        |> json(%{message: "Bad credentials"})
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.current_token
    |> Guardian.revoke

    conn
    |> put_status(200)
    |> json(%{msg: "Good bye"})
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(403)
    |> json(%{msg: "You are not logged in"})
  end
end
