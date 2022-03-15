defmodule Cafe.Joins.GroupTeams do
import Ecto.Query, only: [from: 2]

  alias Cafe.Repo
  alias Cafe.Joins.GroupTeams.GroupTeam

  def create_group_team(group_id, team_id) do
    query =
      from(g in GroupTeam,
        where: g.group_id == ^group_id and g.team_id == ^team_id
      )

    case Repo.all(query) do
      [%GroupTeam{} = group_team | _] ->
        {:ok, group_team}

      _ ->
        %GroupTeam{}
        |> GroupTeam.changeset(%{group_id: group_id, team_id: team_id})
        |> Repo.insert()
    end
  end

  def remove_group_team(group_id, team_id) do
    to_be_removed =
      from(g in GroupTeam,
        where: g.group_id == ^group_id and g.team_id == ^team_id
      )

    Repo.delete_all(to_be_removed)
  end
end
