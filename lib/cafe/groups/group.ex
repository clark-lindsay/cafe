defmodule Cafe.Groups.Group do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Accounts.User
  alias Cafe.Teams.Team

  schema "groups" do
    field :collab_link, :string
    field :focus, :string
    field :work_item_link, :string
    many_to_many :users, User, join_through: "groups_users"
    many_to_many :teams, Team, join_through: "groups_teams"

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:focus, :collab_link, :work_item_link])
    |> validate_required([:focus, :collab_link, :work_item_link])
  end
end
