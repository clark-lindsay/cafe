defmodule Cafe.Repo.Migrations.CreateGroupsUsersTable do
  use Ecto.Migration

  def change do
    create table(:groups_users, primary_key: false) do
      add :group_id, references(:groups)
      add :user_id, references(:users)
    end
  end
end
