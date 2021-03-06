defmodule Cafe.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Cafe.Repo

  alias Cafe.Accounts.User
  alias Cafe.Groups.Group
  alias Cafe.Teams.Team
  alias Cafe.Joins.{GroupTeams, TeamUsers.TeamUser}

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  def list_teams_for_user(%User{} = user), do: list_teams_for_user(user.id)
  def list_teams_for_user(user_id) do
    Repo.all(
      from(t in Team,
        join: tu in TeamUser,
        on: t.id == tu.team_id,
        where: tu.user_id == ^user_id,
        select: t
      )
    )
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  def add_user(%Team{id: team_id}, %User{id: user_id}) do
    Cafe.Joins.TeamUsers.create_team_user(team_id, user_id)
  end

  def remove_user(%Team{id: team_id}, %User{id: user_id}) do
    Cafe.Joins.TeamUsers.remove_team_user(team_id, user_id)
  end

  def add_group(%Team{id: team_id}, %Group{id: group_id}) do
    GroupTeams.create_group_team(group_id, team_id)
  end

  def remove_group(%Team{id: team_id}, %Group{id: group_id}) do
    GroupTeams.remove_group_team(group_id, team_id)
  end
end
