defmodule CafeWeb.HomeLive do
  use CafeWeb, :live_view

  alias Cafe.{Accounts, Groups, Teams, Repo}
  alias Cafe.Joins.GroupUsers
  alias Cafe.Joins.GroupUsers.GroupUser
  alias Cafe.Groups.Group
  alias Cafe.Teams.Team

  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Cafe.PubSub, Groups.pubsub_topic())
      Phoenix.PubSub.subscribe(Cafe.PubSub, GroupUsers.pubsub_topic())
    end

    current_user = Accounts.get_user_by_session_token(session["user_token"])

    teams = Teams.list_teams_for_user(current_user)
    team_changeset = Teams.change_team(%Team{})
    selected_team_id = if Enum.empty?(teams), do: nil, else: hd(teams).id

    groups = Groups.list_groups_for_team(selected_team_id) |> Repo.preload(:users) |> Enum.reverse()
    group_changeset = Groups.change_group(%Group{})

    {:ok,
     assign(socket,
       current_user_id: current_user.id,
       groups: groups,
       group_changeset: group_changeset,
       team_changeset: team_changeset,
       teams: teams,
       selected_team_id: selected_team_id
     ), temporary_assigns: [groups: []]}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def render(assigns) do
    ~H"""
    <%= if @live_action in [:new, :edit] do %>
      <.modal return_to={Routes.home_path(@socket, :index)}>
        <.live_component
          module={CafeWeb.GroupLive.FormComponent}
          id={@group.id || :new}
          title={@page_title}
          action={@live_action}
          group={@group}
          return_to={Routes.home_path(@socket, :index)}
        />
      </.modal>
    <% end %>

    <div>
      <h1 class="text-orange-500">Welcome home!</h1>
    <div class="grid grid-cols-2">
      <h2 class="text-black text-xl">Viewing Groups for:</h2>
      <.form
      let={f}
      for={@team_changeset}
      id="team-select-form"
      phx-change="team-select-change">
      <%= select f, :team_id, team_select_options(@teams), selected: @selected_team_id  %>
      </.form>
    </div> 

      <div class="m-2"><%= live_patch "Add Group", to: Routes.home_path(@socket, :new), class: "bg-amber-700 p-2 m-2 text-white" %></div>
      <div id={"groups-for-team-#{@selected_team_id}"} phx-update="prepend" class="grid grid-cols-2 gap-4 m-4">
        <%= for group <- @groups do %>
          <.group term={group} id={group.id} current_user_id={@current_user_id} />
        <% end %>
      </div>
    </div>
    """
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Group")
    |> assign(:group, %Group{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Cafe - Home")
    |> assign(:group, nil)
  end

  def handle_event("team-select-change", %{"team" => params}, socket) do
    groups =
      if params["team_id"] == "all",
        do: Groups.list_groups(preloads: [:users]) |> Enum.reverse(),
        else: Groups.list_groups_for_team(params["team_id"]) |> Repo.preload(:users)

    {:noreply,
     assign(socket,
       selected_team_id: params["team_id"],
       groups: groups
     )}
  end

  def handle_event("user_join_group", %{"userid" => user_id, "groupid" => group_id}, socket) do
    Groups.add_user(group_id, user_id)
    group = Groups.get_group!(group_id) |> Repo.preload(:users)

    socket = assign(socket, :groups, [group])
    {:noreply, socket}
  end

  def handle_event("user_leave_group", %{"userid" => user_id, "groupid" => group_id}, socket) do
    Groups.remove_user(group_id, user_id)

    {:noreply, socket}
  end

  def handle_info({:create_group, group}, socket) do
    group = Repo.preload(group, :users)
    socket = assign(socket, :groups, [group])

    {:noreply, socket}
  end

  def handle_info({:create_group_user, group_user}, socket) do
    %GroupUser{group_id: group_id} = group_user
    updated_group = Groups.get_group!(group_id) |> Repo.preload(:users)
    socket = update(socket, :groups, fn groups -> [updated_group | groups] end)

    {:noreply, socket}
  end

  def handle_info({:remove_group_user, group_user}, socket) do
    %GroupUser{group_id: group_id} = group_user
    updated_group = Groups.get_group!(group_id) |> Repo.preload(:users)
    socket = update(socket, :groups, fn groups -> [updated_group | groups] end)

    {:noreply, socket}
  end

  def handle_info(any, socket) do
    IO.puts(
      "Module #{__MODULE__} received a message of: #{any} without a clause to handle it. Ignoring."
    )

    {:noreply, socket}
  end

  def group(assigns) do
    %Group{focus: focus, collab_link: collab_link, work_item_link: work_item_link, users: users} =
      assigns.term

    current_user_id = assigns.current_user_id

    ~H"""
    <div id={"#{@id}"} class="border-2 border-stone-500 rounded-md p-2">
      <h1 class="text-xl text-amber-700">Group header</h1>
      <h2 class="text-lg text-red-400"><%= focus %></h2>
      <div>Collaborating At: <a href={collab_link} class="text-blue-500"><%= collab_link %></a></div> 
      <div>Work Item: <a href={work_item_link} class="text-blue-500"><%= work_item_link %></a></div> 

      <div>
        <h3 class="text-md text-amber-700">Users</h3>
        <ul class="flex my-1">
          <%= for user <- users do %>
            <li class="text-black text-md"><%= user.email %></li>
          <% end %>
        </ul>
      </div>

    <%= if Groups.member?(@id, current_user_id) do %>
    <button class="text-md text-red-400 border-stone-500 border-2 rounded-md p-2 hover:bg-gray-200" phx-click="user_leave_group" phx-value-userid={current_user_id} phx-value-groupid={@id}>Leave Group</button>
      <% else %>
    <button class="text-md text-amber-700 border-stone-500 border-2 rounded-md p-2 hover:bg-gray-200" phx-click="user_join_group" phx-value-userid={current_user_id} phx-value-groupid={@id}>Join Group</button>
      <% end %>
    </div>
    """
  end

  defp team_select_options(teams) do
    [{"All", :all} | Enum.map(teams, &{&1.name, &1.id})]
  end
end
