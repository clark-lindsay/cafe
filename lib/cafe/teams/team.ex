defmodule Cafe.Teams.Team do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Accounts.User
  alias Cafe.Groups.Group
  alias Cafe.Joins.{GroupTeam, TeamUser}

  schema "teams" do
    field :description, :string
    field :name, :string
    many_to_many :groups, Group, join_through: GroupTeam, on_delete: :delete_all
    many_to_many :users, User, join_through: TeamUser, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
