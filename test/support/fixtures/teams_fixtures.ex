defmodule Cafe.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cafe.Teams` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Cafe.Teams.create_team()

    team
  end
end
