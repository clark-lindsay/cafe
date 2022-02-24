defmodule Cafe.Repo.Migrations.CreateTeamsUsersTable do
  use Ecto.Migration

  def change do
    create table(:teams_users, primary_key: false) do
      add :team_id, references(:teams)
      add :user_id, references(:users)
    end
  end
end
