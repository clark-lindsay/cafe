defmodule CafeWeb.HomeLive do
  use CafeWeb, :live_view

  alias Cafe.{Accounts, Groups, Repo}
  alias Cafe.Groups.Group

  def mount(_params, session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Cafe.PubSub, Groups.pubsub_topic())

    current_user = Accounts.get_user_by_session_token(session["user_token"])
    time_at_mount = DateTime.utc_now()
    groups = Groups.list_groups(preloads: [:users]) |> Enum.reverse()
    group_changeset = Groups.change_group(%Group{})

    {:ok,
     assign(socket,
       time_at_mount: time_at_mount,
       current_user_email: current_user.email,
       current_user_id: current_user.id,
       groups: groups,
       group_changeset: group_changeset
     ), temporary_assigns: [groups: []]}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-orange-500">Welcome home!</h1>
      <p>The time at mount was <%= @time_at_mount %></p>
      <p>The current user's email is: <span class="text-blue-500"><%= @current_user_email %></span></p>
      <.form let={f} for={@group_changeset} phx-change="validate_group" phx-submit="add_group" >
        <div>
          <%= label f, :focus %>
          <%= text_input f, :focus, phx_debounce: 250 %>
          <%= error_tag f, :focus %>
        </div>

        <%= submit "Add Group", class: "text-lg border-2 m-2 p-2" %>
      </.form>
      <div id="groups" phx-update="prepend" class="grid grid-cols-2 gap-4 m-4">
        <%= for group <- @groups do %>
          <.group term={group} id={group.id} current_user_id={@current_user_id} />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("add_group", %{"group" => params}, socket) do
    params =
      Map.put(params, "collab_link", "example.com")
      |> Map.put("work_item_link", "example.com")

    {:ok, _group} = Groups.create_group(params)
    socket = assign(socket, group_changeset: Groups.change_group(%Group{}))

    {:noreply, socket}
  end

  def handle_event("validate_group", %{"group" => params}, socket) do
    changeset = %Group{} |> Groups.change_group(params) |> Map.put(:action, :insert)

    socket = assign(socket, group_changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("user_join_group", %{"userid" => user_id, "groupid" => group_id}, socket) do
    Groups.add_user(group_id, user_id)
    group = Groups.get_group!(group_id) |> Repo.preload(:users)

    socket = assign(socket, :groups, [group])
    {:noreply, socket}
  end

  def handle_info({:create_group, {:ok, group}}, socket) do
    group = Repo.preload(group, :users)
    socket = assign(socket, :groups, [group])

    {:noreply, socket}
  end

  def handle_info(any, socket) do
    IO.puts(
      "Module #{IO.inspect(__MODULE__)} received a message of: #{IO.inspect(any)} without a clause to handle it. Ignoring."
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
        <h3>Users</h3>
        <%= for user <- users do %>
          <p><%= user.email %></p>
        <% end %>
      </div>
    <button class="text-md bg-amber-700" phx-click="user_join_group" phx-value-userid={current_user_id} phx-value-groupid={@id}>Join Group</button>
    </div>
    """
  end
end
