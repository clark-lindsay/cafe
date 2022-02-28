defmodule Cafe.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Cafe.Repo

  alias Cafe.Accounts.User
  alias Cafe.Groups.Group
  alias Cafe.Teams.Team
  alias Cafe.Joins.{GroupTeam, TeamUser}

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
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
    import Ecto.Query, only: [from: 2]

    case Repo.all(
           from t in TeamUser,
             where: t.team_id == ^team_id and t.user_id == ^user_id
         ) do
      [%TeamUser{} = team_user | _] ->
        {:ok, team_user}

      _ ->
        %TeamUser{}
        |> TeamUser.changeset(%{team_id: team_id, user_id: user_id})
        |> Repo.insert()
    end
  end

  def remove_user(%Team{id: team_id}, %User{id: user_id}) do
    import Ecto.Query

    to_be_removed =
      from(t in TeamUser,
        where: t.team_id == ^team_id and t.user_id == ^user_id
      )

    Repo.delete_all(to_be_removed)
  end

  def add_group(%Team{id: team_id}, %Group{id: group_id}) do
    import Ecto.Query, only: [from: 2]

    same_assocation =
      from(g in GroupTeam,
        where: g.group_id == ^group_id and g.team_id == ^team_id
      )

    case Repo.all(same_assocation) do
      [%GroupTeam{} = group_team | _] ->
        {:ok, group_team}

      _ ->
        %GroupTeam{}
        |> GroupTeam.changeset(%{group_id: group_id, team_id: team_id})
        |> Repo.insert()
    end
  end

  def remove_group(%Team{id: team_id}, %Group{id: group_id}) do
    import Ecto.Query

    to_be_removed =
      from(g in GroupTeam,
        where: g.group_id == ^group_id and g.team_id == ^team_id
      )

    Repo.delete_all(to_be_removed)
  end
end
