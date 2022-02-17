defmodule Cafe.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :focus, :string
      add :collab_link, :string
      add :work_item_link, :string

      timestamps()
    end
  end
end
