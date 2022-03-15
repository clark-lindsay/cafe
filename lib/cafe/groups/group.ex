defmodule Cafe.Groups.Group do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Accounts.User
  alias Cafe.Teams.Team
  alias Cafe.Joins.{GroupTeams.GroupTeam, GroupUsers.GroupUser}

  @required_attrs ~w[focus collab_link work_item_link]a

  schema "groups" do
    field :collab_link, :string
    field :focus, :string
    field :work_item_link, :string
    many_to_many :users, User, join_through: GroupUser, on_delete: :delete_all
    many_to_many :teams, Team, join_through: GroupTeam, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
