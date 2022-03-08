defmodule CafeWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.resource_index_path(@socket, :index)}>
        <.live_component
          module={CafeWeb.ResourceLive.FormComponent}
          id={@resource.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.resource_index_path(@socket, :index)}
          resource: @resource
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="overflow-y-auto fixed inset-0 z-10 pt-6 phx-modal" phx-remove={hide_modal()}>
      <div class="flex justify-center items-end px-4 pt-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 transition-opacity" aria-hidden="true">
          <div class="absolute inset-0 bg-gray-200 opacity-75"></div>
        </div>

        <div id="modal-content" class="inline-block overflow-hidden px-4 pt-5 pb-4 text-left align-bottom bg-white rounded-lg shadow-xl transition-all transform phx-modal-content sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6" role="dialog" aria-modal="true" aria-labelledby="modal-headline"
            phx-click-away={JS.dispatch("click", to: "#modal-close")}
            phx-window-keydown={JS.dispatch("click", to: "#modal-close")}
            phx-key="escape">
          <div class="relative">
            <%= if @return_to do %>
              <%= live_patch "✖",
                id: "modal-close",
                to: @return_to,
                phx_click: hide_modal(),
                class: "inline-flex absolute right-0 text-gray-400 bg-white rounded-md phx-modal-close hover:text-gray-500 focus:outline-none"
                %>
            <% else %>
             <a id="close" href="#" class="inline-flex absolute right-0 text-gray-400 bg-white rounded-md phx-modal-close hover:text-gray-500 focus:outline-none" phx-click={hide_modal()}>✖</a>
            <% end %>
          </div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end
