defmodule Cafe.GroupsTest do
  use Cafe.DataCase, async: true

  alias Cafe.Groups
  alias Cafe.Groups.Group

  import Cafe.{GroupsFixtures, AccountsFixtures}

  describe "groups" do
    @invalid_attrs %{collab_link: nil, focus: nil, work_item_link: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Groups.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Groups.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{
        collab_link: "some collab_link",
        focus: "some focus",
        work_item_link: "some work_item_link"
      }

      assert {:ok, %Group{} = group} = Groups.create_group(valid_attrs)
      assert group.collab_link == "some collab_link"
      assert group.focus == "some focus"
      assert group.work_item_link == "some work_item_link"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()

      update_attrs = %{
        collab_link: "some updated collab_link",
        focus: "some updated focus",
        work_item_link: "some updated work_item_link"
      }

      assert {:ok, %Group{} = group} = Groups.update_group(group, update_attrs)
      assert group.collab_link == "some updated collab_link"
      assert group.focus == "some updated focus"
      assert group.work_item_link == "some updated work_item_link"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, @invalid_attrs)
      assert group == Groups.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end

  describe "add_user/2" do
    test "associates the user to the group" do
      user = user_fixture()
      group = group_fixture()

      Groups.add_user(group, user)
      %Group{users: associated_users} = Repo.preload(group, :users)

      assert [user] == associated_users
    end
  end
end
