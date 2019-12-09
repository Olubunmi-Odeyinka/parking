defmodule Parking.Repo.Migrations.CreateUsesr do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :username, :string
      add :password, :string
      add :hashed_password, :string
      add :role, :string
      add :credit_card_number, :string
      add :account_balance, :float
      add :valid_date, :string
      add :cvv, :string 
      timestamps()
    end
    create unique_index(:users, [:username])
  end
end
