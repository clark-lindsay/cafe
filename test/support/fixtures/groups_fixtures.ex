defmodule Cafe.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cafe.Groups` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        collab_link: "some collab_link",
        focus: "some focus",
        work_item_link: "some work_item_link"
      })
      |> Cafe.Groups.create_group()

    group
  end
end
