defmodule Parking.Repo.Migrations.ChangeStatusType do
  use Ecto.Migration

  def change do
    alter table(:allocations) do
      remove :allocation_status
      add :allocation_status, :string
    end
  end
end
