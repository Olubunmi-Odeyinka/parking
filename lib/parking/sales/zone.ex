defmodule Parking.Sales.Zone do
  use Ecto.Schema
  import Ecto.Changeset
  # @derive {Poison.Encoder, except: [:__meta__]}

  schema "zones" do
    field :zone_type, :string
    field :hourly_rate, :integer
    field :real_time_rate, :float
    has_many(:spaces, Parking.Sales.Space)

    timestamps()
  end

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:zone_type,:hourly_rate, :real_time_rate])
    |> validate_required([:zone_type,:hourly_rate, :real_time_rate])
  end
end



