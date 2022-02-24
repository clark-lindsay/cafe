defmodule Cafe.Teams.TeamsQuery do
  import Ecto.Query

  alias Cafe.Teams.Team
  alias Cafe.Accounts.User

  def new() do
    from(t in Team)
  end

  def for_user(teams_query, %User{} = user) do
    from(t in teams_query,
      join: u in assoc(t, :users),
      on: u.id == ^user.id
    )
  end
end
