defmodule Parking.Repo.Migrations.CreateProcesses do
  use Ecto.Migration

  def change do
    create table(:processes) do
    add :pid, :string
    add :pid_name, :string
    add :status, :boolean
    add :user_id, references(:users)
      timestamps()
    end

  end
end
