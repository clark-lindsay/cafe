defmodule Cafe.Joins.GroupTeams.GroupTeam do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Groups.Group
  alias Cafe.Teams.Team

  @required_attrs ~w[group_id team_id]a

  @primary_key false
  schema "groups_teams" do
    belongs_to :group, Group
    belongs_to :team, Team

    timestamps()
  end

  def changeset(%__MODULE__{} = struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
