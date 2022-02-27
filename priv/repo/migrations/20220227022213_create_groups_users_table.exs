defmodule Cafe.Repo.Migrations.CreateGroupsUsersTable do
  use Ecto.Migration

  def change do
    create table(:groups_users) do
      add :user_id, references(:users), on_delete: :delete_all
      add :group_id, references(:groups), on_delete: :delete_all

      timestamps()
    end
  end
end
