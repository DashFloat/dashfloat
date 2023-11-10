defmodule DashFloatWeb.Components.TableComponents do
  @moduledoc false

  use Phoenix.Component

  import DashFloatWeb.Gettext

  @doc """
  Renders a header with title.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <div class="flex-row items-center justify-between p-4 space-y-3 sm:flex sm:space-y-0 sm:space-x-4">
      <div>
        <h2 class="mr-3 text-lg font-semibold dark:text-white">
          <%= render_slot(@inner_block) %>
        </h2>
        <p :if={@subtitle != []} class="text-gray-500 dark:text-gray-400">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <%= render_slot(@actions) %>
    </div>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.simple_table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.simple_table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def simple_table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full text-sm text-left text-gray-500 dark:text-gray-400">
        <thead class="text-xs uppercase text-gray-700 dark:text-gray-400 bg-gray-50 dark:bg-gray-700">
          <tr>
            <th :for={col <- @col} class="px-6 py-3" scope="col"><%= col[:label] %></th>
            <th :if={@action != []} class="px-6 py-3">
              <span class="sr-only"><%= gettext("Actions") %></span>
            </th>
          </tr>
        </thead>
        <tbody id={@id} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}>
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="bg-white dark:bg-gray-800 border-b dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
          >
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={[
                "px-6 py-4",
                @row_click && "hover:cursor-pointer",
                i == 0 && "font-medium text-gray-900 whitespace-nowrap dark:text-white"
              ]}
            >
              <%= render_slot(col, @row_item.(row)) %>
            </td>
            <td :if={@action != []} class="px-6 py-4 text-right">
              <span
                :for={action <- @action}
                class="font-medium hover:underline text-blue-600 dark:text-blue-500"
              >
                <%= render_slot(action, @row_item.(row)) %>
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
