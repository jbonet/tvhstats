defmodule TVHStats.Repo.Migrations.AddSubscriptionsTable do
  use Ecto.Migration

  @timestamps_opts [type: :utc_datetime_usec]

  def change do
    create table(:subscriptions, primary_key: false) do
      add :hash, :string, primary_key: true, size: 64
      add :user, :string, null: false
      add :channel, :string, null: false
      add :ip, :string, null: false
      add :client, :string, null: false
      add :stream_type, :string, null: false
      add :started_at, :utc_datetime_usec, null: false
      add :stopped_at, :utc_datetime_usec, default: nil, null: true

      timestamps()
    end

    create index(:subscriptions, [:hash], unique: true)
  end
end
