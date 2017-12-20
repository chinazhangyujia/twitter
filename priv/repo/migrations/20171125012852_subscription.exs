defmodule Twitter.Repo.Migrations.Subscription do
  use Ecto.Migration

  def change do
      create table(:subscription) do
          add :subscriber, :string
          add :subscribee, :string
      end
  end
end
