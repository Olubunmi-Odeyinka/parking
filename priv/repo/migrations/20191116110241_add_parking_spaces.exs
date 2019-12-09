defmodule Parking.Repo.Migrations.AddParkingSpaces do
  use Ecto.Migration

  def change do
    create table(:spaces) do
      add(:longitude, :float)
      add(:latitude, :float)
      add(:status, :string)
      add(:user_id, references(:users))
      add(:zone_id, references(:zones))
    end

    create(unique_index(:spaces, [:user_id], name: :user_id_unique))
  end
end
