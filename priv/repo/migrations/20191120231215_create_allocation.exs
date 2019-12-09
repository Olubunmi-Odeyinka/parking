defmodule Parking.Repo.Migrations.CreateAllocation do
  use Ecto.Migration

  def change do
    create table(:allocations) do
    add :start_time, :naive_datetime
    add :end_time, :naive_datetime
    add :is_hourly, :boolean
    add :price, :float
    add :allocation_status, :float
    add :user_id, references(:users)
    add :space_id, references(:spaces)

    timestamps()
    end

  end
end
