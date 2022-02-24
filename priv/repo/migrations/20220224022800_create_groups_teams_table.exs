defmodule Cafe.Repo.Migrations.CreateGroupsTeamsTable do
  use Ecto.Migration

  def change do
    create table(:groups_teams, primary_key: false) do
      add :group_id, references(:groups)
      add :team_id, references(:teams)
    end
  end
end
