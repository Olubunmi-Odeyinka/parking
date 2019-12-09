defmodule Parking.Repo.Migrations.CreateZoneType do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :zone_type, :string
      add :hourly_rate, :integer
      add :real_time_rate, :float

      timestamps()
    end

  end
end
