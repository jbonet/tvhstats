defmodule TVHStats.Subscriptions.Subscription do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @required_fields [
    :started_at,
    :hash,
    :user,
    :channel,
    :ip,
    :client,
    :stream_type
  ]

  @fields [
    :started_at,
    :stopped_at,
    :hash,
    :user,
    :channel,
    :ip,
    :client,
    :stream_type
  ]

  @derive {Jason.Encoder, only: @fields}

  @primary_key {:hash, :string, [autogenerate: false]}

  @type t :: %__MODULE__{
          started_at: DateTime.t(),
          stopped_at: DateTime.t() | nil,
          hash: binary,
          user: binary,
          channel: binary,
          ip: binary
        }

  schema "subscriptions" do
    field :user, :string
    field :channel, :string
    field :ip, :string
    field :client, :string
    field :stream_type, Ecto.Enum, values: [:http, :htsp]
    field :started_at, :utc_datetime_usec
    field :stopped_at, :utc_datetime_usec, default: nil

    timestamps()
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end

  def update_changeset(subscription, attrs) do
    subscription
    |> cast(attrs, @fields)
  end
end
