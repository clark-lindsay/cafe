defmodule Cafe.TeamsTest do
  use Cafe.DataCase

  alias Cafe.Teams
  alias Cafe.Teams.Team
  alias Cafe.Joins.{GroupTeam, TeamUser}

  import Cafe.{AccountsFixtures, GroupsFixtures, TeamsFixtures}

  describe "teams" do
    @invalid_attrs %{description: nil, name: nil}

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Teams.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Team{} = team} = Teams.create_team(valid_attrs)
      assert team.description == "some description"
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Team{} = team} = Teams.update_team(team, update_attrs)
      assert team.description == "some updated description"
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end

  describe "add_user/2" do
    test "associates the user to the team" do
      user = user_fixture()
      team = team_fixture()

      Teams.add_user(team, user)
      %Team{users: associated_users} = Repo.preload(team, :users)

      assert [user] == associated_users
    end

    test "trying to add the same user again does not add a new record" do
      user = user_fixture()
      team = team_fixture()

      {:ok, _} = Teams.add_user(team, user)
      %Team{users: associated_users} = Repo.preload(team, :users)

      assert [user] == associated_users
      assert 1 == Repo.all(TeamUser) |> Enum.count()

      {:ok, _} = Teams.add_user(team, user)
      assert 1 == Repo.all(TeamUser) |> Enum.count()
    end
  end

  describe "remove_user/2" do
    test "removes the association between the user and the team" do
      user = user_fixture()
      team = team_fixture()

      Teams.add_user(team, user)
      Teams.add_user(team, user_fixture())
      %Team{users: associated_users} = Repo.preload(team, :users)

      assert 2 == Enum.count(associated_users)
      assert Enum.member?(associated_users, user)

      {1, _} = Teams.remove_user(team, user)
      %Team{users: associated_users} = Repo.preload(team, :users)

      assert 1 == Enum.count(associated_users)
      refute Enum.member?(associated_users, user)
    end
  end

  describe "add_group/2" do
    test "associates the group to the team" do
      group = group_fixture()
      team = team_fixture()

      Teams.add_group(team, group)
      %Team{groups: associated_groups} = Repo.preload(team, :groups)

      assert [group] == associated_groups
    end

    test "trying to add the same group again does not add a new record" do
      group = group_fixture()
      team = team_fixture()

      {:ok, _} = Teams.add_group(team, group)
      %Team{groups: associated_groups} = Repo.preload(team, :groups)

      assert [group] == associated_groups
      assert 1 == Repo.all(GroupTeam) |> Enum.count()

      {:ok, _} = Teams.add_group(team, group)
      assert 1 == Repo.all(GroupTeam) |> Enum.count()
    end
  end

  describe "remove_group/2" do
    test "removes the association between the group and the team" do
      group = group_fixture()
      team = team_fixture()

      Teams.add_group(team, group)
      Teams.add_group(team, group_fixture())
      %Team{groups: associated_groups} = Repo.preload(team, :groups)

      assert 2 == Enum.count(associated_groups)
      assert Enum.member?(associated_groups, group)

      {1, _} = Teams.remove_group(team, group)
      %Team{groups: associated_groups} = Repo.preload(team, :groups)

      assert 1 == Enum.count(associated_groups)
      refute Enum.member?(associated_groups, group)
    end
  end
end
