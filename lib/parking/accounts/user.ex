defmodule Parking.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  # @derive {Poison.Encoder, except: [:__meta__]}

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string)
    field(:role, :string)
    field(:credit_card_number, :string)
    field(:account_balance, :float)
    field(:valid_date, :string)
    field(:cvv, :string)
    field(:monthly_payment, :boolean)

    has_one(:spaces, Parking.Sales.Space)
    has_many(:processes, Parking.Sales.Processcontrol)
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :username, :password, :role, :credit_card_number, :account_balance, :valid_date, :cvv, :monthly_payment])
    |> validate_required([:name, :email, :username, :role])
    |> unique_constraint(:username)
    |> validate_length(:password, min: 6)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, hashed_password: Pbkdf2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
