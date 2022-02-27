defmodule Cafe.Joins.GroupUser do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cafe.Accounts.User
  alias Cafe.Groups.Group

  @primary_key false
  schema "groups_users" do
    belongs_to :user, User
    belongs_to :group, Group

    timestamps()
  end

  def changeset(%__MODULE__{} = struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:user_id, :group_id])
    |> validate_required([:user_id, :group_id])
  end
end
