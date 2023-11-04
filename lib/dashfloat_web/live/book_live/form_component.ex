defmodule DashFloatWeb.BookLive.FormComponent do
  use DashFloatWeb, :live_component

  alias DashFloat.Budgeting

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="book-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Book</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{book: book} = assigns, socket) do
    changeset = Budgeting.change_book(book)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    changeset =
      socket.assigns.book
      |> Budgeting.change_book(book_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    save_book(socket, socket.assigns.action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Budgeting.update_book(socket.assigns.book, book_params) do
      {:ok, book} ->
        notify_parent({:saved, book})

        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_book(socket, :new, book_params) do
    case Budgeting.create_book(book_params) do
      {:ok, book} ->
        notify_parent({:saved, book})

        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
