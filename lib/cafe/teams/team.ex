defmodule Cafe.Teams.Team do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Accounts.User
  alias Cafe.Groups.Group

  schema "teams" do
    field :description, :string
    field :name, :string
    many_to_many :users, User, join_through: "teams_users"
    many_to_many :groups, Group, join_through: "groups_teams"

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
