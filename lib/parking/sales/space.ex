defmodule Parking.Sales.Space do
  use Ecto.Schema
  import Ecto.Changeset
  # @derive {Poison.Encoder, except: [:__meta__]}

  schema "spaces" do
    field(:longitude, :float)
    field(:latitude, :float)
    field(:status, :string)
    belongs_to(:user, Parking.Account.User, foreign_key: :user_id)
    belongs_to(:zone, Parking.Sales.Zone, foreign_key: :zone_id)
    has_many(:allocations, Parking.Sales.Allocation)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:longitude, :latitude, :status, :zone_id, :user_id])
    |> validate_required([:longitude, :latitude, :status, :zone_id])
    |> unique_constraint(:user_id, name: "user_id_unique", message: "Cant Have two active Parking")
  end
end
