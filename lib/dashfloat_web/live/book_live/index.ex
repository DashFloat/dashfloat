defmodule DashFloatWeb.BookLive.Index do
  use DashFloatWeb, :live_view

  alias DashFloat.Budgeting
  alias DashFloat.Budgeting.Schemas.Book

  @impl true
  def render(assigns) do
    ~H"""
    <TableComponents.header>
      Your Books
      <:actions>
        <.link patch={~p"/books/new"}>
          <FormComponents.button class="flex items-center justify-center space-x-4">
            <LayoutComponents.icon name="hero-plus-mini" class="mr-0.8" /> New Book
          </FormComponents.button>
        </.link>
      </:actions>
    </TableComponents.header>

    <TableComponents.simple_table id="books" rows={@streams.books}>
      <:col :let={{_id, book}} label="Name"><%= book.name %></:col>
      <:action :let={{_id, book}}>
        <.link patch={~p"/books/#{book}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, book}}>
        <.link
          phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </TableComponents.simple_table>

    <LayoutComponents.modal
      :if={@live_action in [:new, :edit]}
      id="book-modal"
      show
      on_cancel={JS.patch(~p"/books")}
    >
      <.live_component
        module={DashFloatWeb.BookLive.FormComponent}
        id={@book.id || :new}
        title={@page_title}
        action={@live_action}
        book={@book}
        patch={~p"/books"}
        current_user_id={@current_user.id}
      />
    </LayoutComponents.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :books, Budgeting.list_books(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Budgeting.get_book(id, socket.assigns.current_user.id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, %Book{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Books")
    |> assign(:book, nil)
  end

  @impl true
  def handle_info({DashFloatWeb.BookLive.FormComponent, {:saved, book}}, socket) do
    {:noreply, stream_insert(socket, :books, book)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Budgeting.get_book(id, socket.assigns.current_user.id)
    {:ok, _} = Budgeting.delete_book(book, socket.assigns.current_user.id)

    {:noreply, stream_delete(socket, :books, book)}
  end
end
