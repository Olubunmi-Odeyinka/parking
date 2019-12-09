defmodule Parking.Sales.Processcontrol do
  use Ecto.Schema
  import Ecto.Changeset


   schema "processes" do
    field(:pid, :string)
    field(:pid_name, :string)
    field(:status, :boolean)
    belongs_to :user, Parking.Account.User, foreign_key: :user_id
    timestamps()
  end

  @doc false
  def changeset(processcontrol, attrs) do
    processcontrol
    |> cast(attrs, [:pid, :pid_name, :status, :user_id])
    |> validate_required([])
  end
end
