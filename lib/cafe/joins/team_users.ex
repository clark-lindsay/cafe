defmodule Cafe.Joins.TeamUsers do
  import Ecto.Query, only: [from: 2]

  alias Cafe.Joins.TeamUsers.TeamUser
  alias Cafe.Repo

  @topic "#{IO.inspect(__MODULE__)}"

  def create_team_user(team_id, user_id) do
    with {:ok, inserted_team_user} <- insert_team_user(team_id, user_id),
         :ok <- publish_create_team_user(inserted_team_user),
         do: {:ok, inserted_team_user}
  end

  def remove_team_user(team_id, user_id) do
    team_user = %TeamUser{team_id: team_id, user_id: user_id}

    with :ok <- delete_team_user(team_id, user_id),
         :ok <- publish_remove_team_user(team_user),
         do: :ok
  end

  defp insert_team_user(team_id, user_id) do
    case Repo.all(from(t in TeamUser, where: t.team_id == ^team_id and t.user_id == ^user_id)) do
      [%TeamUser{} = team_user | _] ->
        {:ok, team_user}

      _ ->
        %TeamUser{}
        |> TeamUser.changeset(%{team_id: team_id, user_id: user_id})
        |> Repo.insert()
    end
  end

  defp delete_team_user(team_id, user_id) do
    to_be_removed =
      from(t in TeamUser,
        where: t.team_id == ^team_id and t.user_id == ^user_id
      )

    Repo.delete_all(to_be_removed)
  end

  defp publish_create_team_user(%TeamUser{} = team_user) do
    :ok = Phoenix.PubSub.broadcast(Cafe.PubSub, @topic, {:create_team_user, team_user})
    :ok
  end

  defp publish_remove_team_user(%TeamUser{} = team_user) do
    :ok = Phoenix.PubSub.broadcast(Cafe.PubSub, @topic, {:remove_team_user, team_user})
    :ok
  end

  def pubsub_topic(), do: @topic
end
