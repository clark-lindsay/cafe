defmodule Cafe.Repo.Migrations.CreateGroupsTeamsTable do
  use Ecto.Migration

  def change do
    create table(:groups_teams) do
      add :group_id, references(:groups), on_delete: :delete_all
      add :team_id, references(:teams), on_delete: :delete_all

      timestamps()
    end
  end
end
