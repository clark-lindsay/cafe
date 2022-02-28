defmodule Cafe.Groups do
  @moduledoc """
  The Groups context.
  """

  @topic "#{IO.inspect(__MODULE__)}"

  import Ecto.Query, warn: false
  alias Cafe.Repo

  alias Cafe.Groups.Group
  alias Cafe.Accounts.User
  alias Cafe.Joins.GroupUser

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    with group <- Group.changeset(%Group{}, attrs),
         {:ok, group} <- Repo.insert(group),
         {:ok, group} <- publish_create_group({:ok, group}) do
      {:ok, group}
    end
  end

  defp publish_create_group({:ok, group}) do
    :ok =
      Phoenix.PubSub.broadcast(
        Cafe.PubSub,
        @topic,
        {:create_group, group}
      )

    {:ok, group}
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  def pubsub_topic(), do: @topic

  @doc """
  Associates a `Cafe.AccountsUser` to the `Group` using the
  `Cafe.JoinsGroupUser` schema

  ## Examples

      iex> add_user(group, user)
      %Cafe.Joins.GroupUser{}
  """
  def add_user(%Group{id: group_id}, %User{id: user_id}) do
    import Ecto.Query, only: [from: 2]

    case Repo.all(from(g in GroupUser, where: g.group_id == ^group_id and g.user_id == ^user_id)) do
      [%GroupUser{} = group_user | _] ->
        {:ok, group_user}

      _ ->
        %GroupUser{}
        |> GroupUser.changeset(%{group_id: group_id, user_id: user_id})
        |> Repo.insert()
    end
  end
end
