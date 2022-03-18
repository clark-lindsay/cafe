defmodule Cafe.Joins.GroupTeams do
import Ecto.Query, only: [from: 2]

  alias Cafe.Repo
  alias Cafe.Joins.GroupTeams.GroupTeam

  @topic "#{IO.inspect(__MODULE__)}"

  def create_group_team(group_id, team_id) do
    with {:ok, inserted_group_team} <- insert_group_team(group_id, team_id),
         :ok <- publish_create_group_team(inserted_group_team),
    do: {:ok, inserted_group_team}
  end

  def remove_group_team(group_id, team_id) do
    group_team = %GroupTeam{group_id: group_id, team_id: team_id}

    with :ok <- delete_group_team(group_team),
         :ok <- publish_remove_group_team(group_team),
    do: :ok
  end

  defp insert_group_team(group_id, team_id) do
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

  defp delete_group_team(%GroupTeam{group_id: group_id, team_id: team_id}) do
    to_be_removed =
      from(g in GroupTeam,
        where: g.group_id == ^group_id and g.team_id == ^team_id
      )

    Repo.delete_all(to_be_removed)
  end

  defp publish_create_group_team(%GroupTeam{} = group_team) do
    Phoenix.PubSub.broadcast(Cafe.PubSub, @topic, {:create_group_team, group_team})
  end

  defp publish_remove_group_team(%GroupTeam{} = group_team) do
    Phoenix.PubSub.broadcast(Cafe.PubSub, @topic, {:remove_group_team, group_team})
  end

  def pubsub_topic(), do: @topic
end
