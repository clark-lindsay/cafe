defmodule Cafe.Repo.Migrations.CreateTeamsUsersTable do
  use Ecto.Migration

  def change do
    create table(:teams_users) do
      add :user_id, references(:users), on_delete: :delete_all
      add :team_id, references(:teams), on_delete: :delete_all

      timestamps()
    end
  end
end
