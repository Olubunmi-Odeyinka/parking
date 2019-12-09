defmodule ParkingWeb.Api.UserController do
  use ParkingWeb, :controller
  alias Parking.Repo
  alias Parking.Accounts.User
  alias Parking.Authentication
  alias Ecto.Changeset

  def pretty_json(conn, status_code, data) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(status_code, Poison.encode!(data, pretty: true))
  end

  def index(conn, _params) do
    users = Repo.all(User)
    pretty_json(conn, :ok, users)
  end

  def create(conn, %{
        "username" => username,
        "password" => password,
        "role" => role,
        "name" => name,
        "email" => email
      }) do
    changeset =
      User.changeset(%User{}, %{
        username: username,
        password: password,
        name: name,
        role: role,
        email: email
      })

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> Plug.Conn.resp(200, "Successful")
        |> Plug.Conn.send_resp()

      # (to: user_path(conn, :index))
      {:error, changeset} ->
        conn
        |> Plug.Conn.resp(400, "Error")
        |> Plug.Conn.send_resp()
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        pretty_json(conn, :no_content, changeset)

      # (to: user_path(conn, :index))
      {:error, changeset} ->
        pretty_json(conn, :method_not_allowed, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    pretty_json(conn, :ok, user)
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    Repo.delete!(user)

    pretty_json(conn, :method_not_allowed, user)
  end

  def save_monthly_plan(conn, %{"monthly_payment" => monthly_payment}) do
    user = Authentication.load_current_user(conn)
    User.changeset(user) |> Changeset.put_change(:monthly_payment, monthly_payment)
      |> Repo.update
      pretty_json(conn, :ok, %{"monthly_payment" => monthly_payment})
  end

  def get_monthly_payment(conn, %{}) do
    user = Authentication.load_current_user(conn)
    pretty_json(conn, :ok, %{"monthly_payment" => user.monthly_payment})
  end

end
