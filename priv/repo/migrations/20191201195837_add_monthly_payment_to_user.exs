defmodule Parking.Repo.Migrations.AddMonthlyPaymentToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :monthly_payment, :boolean
    end
  end
end
