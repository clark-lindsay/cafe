defmodule Cafe.Joins.GroupUsers do
  alias Cafe.Repo
  alias Cafe.Joins.GroupUsers.GroupUser

  @topic "#{IO.inspect(__MODULE__)}"

  def create_group_user(group_id, user_id) do
    with {:ok, inserted_group_user} <- insert_group_user(group_id, user_id),
         {:ok, _group_user} <- publish_create_group_user(inserted_group_user) do
      {:ok, inserted_group_user}
    end
  end

  def remove_group_user(group_id, user_id) do
    group_user = %GroupUser{group_id: group_id, user_id: user_id}

    with :ok <- delete_group_user(group_id, user_id),
         :ok <- publish_remove_group_user(group_user),
         do: :ok
  end

  defp insert_group_user(group_id, user_id) do
    import Ecto.Query, only: [from: 2]

    case Repo.all(
           from(g in GroupUser,
             where: g.group_id == ^group_id and g.user_id == ^user_id
           )
         ) do
      [%GroupUser{} = group_user | _] ->
        {:ok, group_user}

      _ ->
        %GroupUser{}
        |> GroupUser.changeset(%{group_id: group_id, user_id: user_id})
        |> Repo.insert()
    end
  end

  defp publish_create_group_user(group_user) do
    :ok = Phoenix.PubSub.broadcast(Cafe.PubSub, @topic, {:create_group_user, group_user})

    {:ok, group_user}
  end

  defp delete_group_user(group_id, user_id) do
    import Ecto.Query, only: [from: 2]

    from(g in GroupUser,
      where: g.group_id == ^group_id and g.user_id == ^user_id
    )
    |> Repo.delete_all()

    :ok
  end

  defp publish_remove_group_user(group_user) do
    :ok = Phoenix.PubSub.broadcast(Cafe.PubSub, @topic, {:remove_group_user, group_user})
    :ok
  end

  def pubsub_topic(), do: @topic
end
