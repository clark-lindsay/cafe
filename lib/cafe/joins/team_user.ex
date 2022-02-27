defmodule Cafe.Joins.TeamUser do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Accounts.User
  alias Cafe.Teams.Team

  @primary_key false
  schema "teams_users" do
    belongs_to :user, User
    belongs_to :team, Team

    timestamps()
  end

  def changeset(%__MODULE__{} = struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
  end
end
