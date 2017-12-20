defmodule Twitter.Repo.Migrations.User do
  use Ecto.Migration

  def change do
      create table(:user_table) do
          add :account, :string
          add :password, :string
          add :publickeys, :string
      end
  end
end
