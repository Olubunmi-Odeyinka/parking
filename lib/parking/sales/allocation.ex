defmodule Parking.Sales.Allocation do
  use Ecto.Schema
  import Ecto.Changeset
  # @derive {Poison.Encoder, except: [:__meta__]}

  schema "allocations" do
    field(:start_time, :naive_datetime)
    field(:end_time, :naive_datetime)
    field(:is_hourly, :boolean)
    field(:price, :float)
    field(:allocation_status, :string)
    belongs_to :user, Parking.Account.User, foreign_key: :user_id
    belongs_to :space, Parking.Sales.Space , foreign_key: :space_id
    timestamps()
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:start_time, :end_time, :is_hourly, :user_id, :space_id, :price, :allocation_status])
    |> validate_required([:start_time, :space_id, :is_hourly])
  end
end
